-- ========================================
-- 커뮤니티 성능 최적화를 위한 인덱스 생성
-- ========================================

-- 1. community_posts 테이블 인덱스
-- ========================================

-- 인기 게시글 조회 최적화 (당일 + 좋아요순)
-- 조건: is_deleted = false, created_at >= today, like_count >= 1
-- 정렬: like_count DESC, created_at DESC
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_posts_daily_popular 
ON community_posts (like_count DESC, created_at DESC) 
WHERE is_deleted = false AND like_count >= 1;

-- 카테고리별 게시글 조회 최적화
-- 조건: category_id, is_deleted = false
-- 정렬: created_at DESC (최신순)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_posts_category_latest 
ON community_posts (category_id, created_at DESC) 
WHERE is_deleted = false;

-- 카테고리별 좋아요순 조회 최적화
-- 조건: category_id, is_deleted = false
-- 정렬: like_count DESC, created_at DESC
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_posts_category_popular 
ON community_posts (category_id, like_count DESC, created_at DESC) 
WHERE is_deleted = false;

-- 전체 게시글 최신순 조회 최적화
-- 조건: is_deleted = false
-- 정렬: created_at DESC
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_posts_latest 
ON community_posts (created_at DESC) 
WHERE is_deleted = false;

-- 전체 게시글 좋아요순 조회 최적화
-- 조건: is_deleted = false
-- 정렬: like_count DESC, created_at DESC
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_posts_popular 
ON community_posts (like_count DESC, created_at DESC) 
WHERE is_deleted = false;

-- 작성자별 게시글 조회 최적화
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_posts_author 
ON community_posts (author_id, created_at DESC) 
WHERE is_deleted = false;

-- 2. community_comments 테이블 인덱스
-- ========================================

-- 게시글별 최상위 댓글 조회 최적화 (페이징)
-- 조건: post_id, parent_comment_id IS NULL
-- 정렬: like_count DESC, created_at DESC
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_comments_post_top_level 
ON community_comments (post_id, like_count DESC, created_at DESC) 
WHERE parent_comment_id IS NULL;

-- 답글 조회 최적화
-- 조건: parent_comment_id NOT NULL
-- 정렬: created_at ASC (답글은 오래된 순)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_comments_replies 
ON community_comments (parent_comment_id, created_at ASC) 
WHERE parent_comment_id IS NOT NULL;

-- 댓글 작성자별 조회 최적화
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_comments_author 
ON community_comments (author_id, created_at DESC);

-- 3. community_likes 테이블 인덱스
-- ========================================

-- 사용자별 좋아요 게시글 조회 최적화
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_likes_user_posts 
ON community_likes (user_id, post_id) 
WHERE post_id IS NOT NULL;

-- 사용자별 좋아요 댓글 조회 최적화
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_likes_user_comments 
ON community_likes (user_id, comment_id) 
WHERE comment_id IS NOT NULL;

-- 게시글별 좋아요 수 집계 최적화
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_likes_post_aggregation 
ON community_likes (post_id) 
WHERE post_id IS NOT NULL;

-- 댓글별 좋아요 수 집계 최적화
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_community_likes_comment_aggregation 
ON community_likes (comment_id) 
WHERE comment_id IS NOT NULL;

-- 4. user_profiles 테이블 인덱스
-- ========================================

-- 여러 사용자 프로필 조회 최적화 (.inFilter 용)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_profiles_user_id 
ON user_profiles (user_id);

-- 닉네임 검색 최적화
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_profiles_nickname 
ON user_profiles USING gin (nickname gin_trgm_ops);

-- ========================================
-- 분석 정보 업데이트
-- ========================================

-- 쿼리 플래너가 인덱스를 효율적으로 사용할 수 있도록 통계 정보 업데이트
ANALYZE community_posts;
ANALYZE community_comments;
ANALYZE community_likes;
ANALYZE user_profiles;

-- ========================================
-- 인덱스 생성 확인
-- ========================================

-- 생성된 인덱스 확인 쿼리
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename IN ('community_posts', 'community_comments', 'community_likes', 'user_profiles')
ORDER BY tablename, indexname;