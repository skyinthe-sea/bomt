-- ========================================
-- 커뮤니티 검색 최적화 마이그레이션
-- ========================================
-- 
-- 주요 기능:
-- 1. PostgreSQL Full-Text Search 인덱스 생성
-- 2. 다국어 검색 지원 (한국어, 영어, 일본어)
-- 3. 최적화된 검색 RPC 함수
-- 4. 검색 분석 테이블
-- 5. 인기 검색어 및 제안어 기능

-- =====================================
-- 1. Full-Text Search 인덱스 생성
-- =====================================

-- 한국어 텍스트 검색을 위한 커스텀 설정
CREATE TEXT SEARCH CONFIGURATION korean (COPY = pg_catalog.simple);

-- 커뮤니티 게시글에 Full-Text Search 컬럼 추가
ALTER TABLE community_posts 
ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- 검색 벡터 업데이트 함수
CREATE OR REPLACE FUNCTION update_community_post_search_vector()
RETURNS trigger AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('korean', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('korean', COALESCE(NEW.content, '')), 'B') ||
    setweight(to_tsvector('simple', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('simple', COALESCE(NEW.content, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
DROP TRIGGER IF EXISTS community_posts_search_vector_update ON community_posts;
CREATE TRIGGER community_posts_search_vector_update
  BEFORE INSERT OR UPDATE ON community_posts
  FOR EACH ROW EXECUTE FUNCTION update_community_post_search_vector();

-- 기존 데이터에 대한 검색 벡터 업데이트
UPDATE community_posts SET search_vector = 
  setweight(to_tsvector('korean', COALESCE(title, '')), 'A') ||
  setweight(to_tsvector('korean', COALESCE(content, '')), 'B') ||
  setweight(to_tsvector('simple', COALESCE(title, '')), 'A') ||
  setweight(to_tsvector('simple', COALESCE(content, '')), 'B');

-- GIN 인덱스 생성 (Full-Text Search 최적화)
CREATE INDEX IF NOT EXISTS idx_community_posts_search_vector 
ON community_posts USING GIN(search_vector);

-- 추가 최적화 인덱스
CREATE INDEX IF NOT EXISTS idx_community_posts_category_created 
ON community_posts(category, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_community_posts_likes_created 
ON community_posts(like_count DESC, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_community_posts_comments_created 
ON community_posts(comment_count DESC, created_at DESC);

-- =====================================
-- 2. 검색 분석 테이블
-- =====================================

CREATE TABLE IF NOT EXISTS search_analytics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  query TEXT NOT NULL,
  result_count INTEGER DEFAULT 0,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 검색 분석 인덱스
CREATE INDEX IF NOT EXISTS idx_search_analytics_query 
ON search_analytics(query);

CREATE INDEX IF NOT EXISTS idx_search_analytics_created 
ON search_analytics(created_at DESC);

-- =====================================
-- 3. 최적화된 검색 RPC 함수
-- =====================================

-- 메인 검색 함수
CREATE OR REPLACE FUNCTION search_community_posts_optimized(
  search_query TEXT,
  category_filter TEXT DEFAULT NULL,
  sort_by TEXT DEFAULT 'relevance',
  result_limit INTEGER DEFAULT 20,
  result_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  title TEXT,
  content TEXT,
  category TEXT,
  author_id UUID,
  author_name TEXT,
  author_avatar_url TEXT,
  like_count INTEGER,
  comment_count INTEGER,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE,
  relevance_score REAL
) 
LANGUAGE plpgsql
AS $$
DECLARE
  query_tsquery tsquery;
BEGIN
  -- 검색 쿼리 전처리
  BEGIN
    query_tsquery := plainto_tsquery('korean', search_query);
    
    -- 한국어 검색이 실패하면 simple로 시도
    IF query_tsquery IS NULL OR query_tsquery = ''::tsquery THEN
      query_tsquery := plainto_tsquery('simple', search_query);
    END IF;
    
    -- 그래도 실패하면 LIKE 검색 준비
    IF query_tsquery IS NULL OR query_tsquery = ''::tsquery THEN
      query_tsquery := to_tsquery('simple', quote_literal(search_query) || ':*');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- 모든 검색이 실패하면 LIKE 검색으로 폴백
      query_tsquery := NULL;
  END;

  RETURN QUERY
  SELECT 
    cp.id,
    cp.title,
    cp.content,
    cp.category,
    cp.author_id,
    COALESCE(up.name, up.email, '익명') as author_name,
    up.avatar_url as author_avatar_url,
    cp.like_count,
    cp.comment_count,
    cp.created_at,
    cp.updated_at,
    CASE 
      WHEN query_tsquery IS NOT NULL THEN
        ts_rank_cd(cp.search_vector, query_tsquery, 32)
      ELSE
        -- LIKE 검색 시 관련도 계산
        CASE 
          WHEN cp.title ILIKE '%' || search_query || '%' THEN 1.0
          WHEN cp.content ILIKE '%' || search_query || '%' THEN 0.5
          ELSE 0.1
        END
    END as relevance_score
  FROM community_posts cp
  LEFT JOIN user_profiles up ON cp.author_id = up.id
  WHERE 
    cp.is_deleted = FALSE
    AND (category_filter IS NULL OR cp.category = category_filter)
    AND (
      -- Full-Text Search 우선
      (query_tsquery IS NOT NULL AND cp.search_vector @@ query_tsquery)
      OR
      -- 폴백: LIKE 검색
      (query_tsquery IS NULL AND (
        cp.title ILIKE '%' || search_query || '%' 
        OR cp.content ILIKE '%' || search_query || '%'
      ))
    )
  ORDER BY 
    CASE 
      WHEN sort_by = 'relevance' THEN 
        CASE 
          WHEN query_tsquery IS NOT NULL THEN
            ts_rank_cd(cp.search_vector, query_tsquery, 32)
          ELSE
            CASE 
              WHEN cp.title ILIKE '%' || search_query || '%' THEN 1.0
              WHEN cp.content ILIKE '%' || search_query || '%' THEN 0.5
              ELSE 0.1
            END
        END
      ELSE 0
    END DESC,
    CASE WHEN sort_by = 'created_at' THEN cp.created_at END DESC,
    CASE WHEN sort_by = 'like_count' THEN cp.like_count END DESC,
    CASE WHEN sort_by = 'comment_count' THEN cp.comment_count END DESC,
    cp.created_at DESC
  LIMIT result_limit
  OFFSET result_offset;
END;
$$;

-- =====================================
-- 4. 인기 검색어 함수
-- =====================================

CREATE OR REPLACE FUNCTION get_popular_search_terms(
  result_limit INTEGER DEFAULT 10
)
RETURNS TABLE (query TEXT)
LANGUAGE sql
AS $$
  SELECT sa.query
  FROM search_analytics sa
  WHERE sa.created_at >= NOW() - INTERVAL '7 days'
    AND LENGTH(sa.query) >= 2
    AND sa.result_count > 0
  GROUP BY sa.query
  ORDER BY COUNT(*) DESC, MAX(sa.created_at) DESC
  LIMIT result_limit;
$$;

-- =====================================
-- 5. 검색 제안어 함수
-- =====================================

CREATE OR REPLACE FUNCTION get_search_suggestions(
  search_input TEXT,
  result_limit INTEGER DEFAULT 5
)
RETURNS TABLE (suggestion TEXT)
LANGUAGE sql
AS $$
  -- 최근 성공한 검색어 중에서 유사한 것들 찾기
  SELECT DISTINCT sa.query as suggestion
  FROM search_analytics sa
  WHERE sa.created_at >= NOW() - INTERVAL '30 days'
    AND sa.result_count > 0
    AND LENGTH(sa.query) >= 2
    AND (
      sa.query ILIKE search_input || '%'
      OR sa.query ILIKE '%' || search_input || '%'
      OR similarity(sa.query, search_input) > 0.3
    )
  ORDER BY 
    CASE WHEN sa.query ILIKE search_input || '%' THEN 1 ELSE 2 END,
    LENGTH(sa.query),
    sa.query
  LIMIT result_limit;
$$;

-- =====================================
-- 6. 권한 설정
-- =====================================

-- RPC 함수들에 대한 실행 권한 부여
GRANT EXECUTE ON FUNCTION search_community_posts_optimized TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_popular_search_terms TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_search_suggestions TO anon, authenticated;

-- 검색 분석 테이블 권한
GRANT SELECT, INSERT ON search_analytics TO authenticated;
GRANT SELECT ON search_analytics TO anon;

-- =====================================
-- 7. Row Level Security 정책
-- =====================================

ALTER TABLE search_analytics ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 검색 기록만 볼 수 있음 (선택사항)
CREATE POLICY "Users can view own search history" ON search_analytics
  FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

-- 인증된 사용자는 검색 분석 데이터를 추가할 수 있음
CREATE POLICY "Authenticated users can insert search analytics" ON search_analytics
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- =====================================
-- 8. 성능 최적화를 위한 추가 설정
-- =====================================

-- 검색 관련 PostgreSQL 설정 최적화 (선택사항)
-- ALTER SYSTEM SET default_text_search_config = 'korean';

-- 통계 업데이트 (쿼리 플래너 최적화)
ANALYZE community_posts;
ANALYZE search_analytics;

-- =====================================
-- 9. 테스트 데이터 (개발용)
-- =====================================

-- 개발 환경에서 테스트용 검색 분석 데이터 추가
INSERT INTO search_analytics (query, result_count, created_at) VALUES
  ('육아 팁', 15, NOW() - INTERVAL '1 day'),
  ('이유식', 8, NOW() - INTERVAL '2 days'),
  ('수면교육', 12, NOW() - INTERVAL '3 days'),
  ('기저귀', 5, NOW() - INTERVAL '4 days'),
  ('모유수유', 20, NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

-- 성공 메시지
DO $$
BEGIN
  RAISE NOTICE '✅ 커뮤니티 검색 최적화 마이그레이션이 성공적으로 완료되었습니다.';
  RAISE NOTICE '📊 Full-Text Search 인덱스가 생성되었습니다.';
  RAISE NOTICE '🔍 검색 RPC 함수들이 생성되었습니다.';
  RAISE NOTICE '📈 검색 분석 시스템이 설정되었습니다.';
END $$;