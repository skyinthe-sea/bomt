-- 커뮤니티 기능을 위한 모든 테이블 생성 SQL (통합버전)
-- Supabase 대시보드에서 SQL Editor를 통해 실행하세요

-- ============================================
-- 1. 사용자 프로필 테이블 (먼저 생성)
-- ============================================
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE,
    nickname TEXT NOT NULL UNIQUE,
    profile_image_url TEXT,
    bio TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 2. 커뮤니티 카테고리 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS community_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    color TEXT DEFAULT '#6366f1',
    icon TEXT DEFAULT 'category',
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 3. 커뮤니티 게시글 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS community_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id TEXT NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES community_categories(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    images TEXT[] DEFAULT '{}',
    like_count INTEGER NOT NULL DEFAULT 0,
    comment_count INTEGER NOT NULL DEFAULT 0,
    view_count INTEGER NOT NULL DEFAULT 0,
    is_deleted BOOLEAN NOT NULL DEFAULT false,
    is_pinned BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 4. 커뮤니티 댓글 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS community_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    author_id TEXT NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES community_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    like_count INTEGER NOT NULL DEFAULT 0,
    is_deleted BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 5. 커뮤니티 좋아요 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS community_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES community_comments(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- 하나의 사용자는 하나의 게시글/댓글에 하나의 좋아요만 가능
    CONSTRAINT unique_post_like UNIQUE (user_id, post_id),
    CONSTRAINT unique_comment_like UNIQUE (user_id, comment_id),
    CONSTRAINT check_like_target CHECK (
        (post_id IS NOT NULL AND comment_id IS NULL) OR 
        (post_id IS NULL AND comment_id IS NOT NULL)
    )
);

-- ============================================
-- 6. 알림 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id TEXT NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    sender_id TEXT REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- 'like', 'comment', 'reply', 'mention'
    title TEXT NOT NULL,
    content TEXT,
    reference_id TEXT, -- 참조하는 게시글/댓글 ID
    reference_type TEXT, -- 'post' or 'comment'
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 인덱스 생성 (성능 최적화)
-- ============================================

-- user_profiles 인덱스
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_nickname ON user_profiles(nickname);

-- community_categories 인덱스
CREATE INDEX IF NOT EXISTS idx_community_categories_slug ON community_categories(slug);
CREATE INDEX IF NOT EXISTS idx_community_categories_active ON community_categories(is_active, display_order);

-- community_posts 인덱스
CREATE INDEX IF NOT EXISTS idx_community_posts_author ON community_posts(author_id);
CREATE INDEX IF NOT EXISTS idx_community_posts_category ON community_posts(category_id);
CREATE INDEX IF NOT EXISTS idx_community_posts_created_at ON community_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_community_posts_like_count ON community_posts(like_count DESC);
CREATE INDEX IF NOT EXISTS idx_community_posts_not_deleted ON community_posts(is_deleted) WHERE is_deleted = false;

-- community_comments 인덱스
CREATE INDEX IF NOT EXISTS idx_community_comments_post ON community_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_community_comments_author ON community_comments(author_id);
CREATE INDEX IF NOT EXISTS idx_community_comments_parent ON community_comments(parent_comment_id);
CREATE INDEX IF NOT EXISTS idx_community_comments_created_at ON community_comments(created_at ASC);

-- community_likes 인덱스
CREATE INDEX IF NOT EXISTS idx_community_likes_user ON community_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_community_likes_post ON community_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_community_likes_comment ON community_likes(comment_id);

-- notifications 인덱스
CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON notifications(recipient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_sender ON notifications(sender_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(recipient_id, is_read) WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_reference ON notifications(reference_id, reference_type);

-- ============================================
-- Updated_at 트리거 설정
-- ============================================

-- updated_at 트리거 함수 (이미 생성되어 있지 않다면)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- 각 테이블에 updated_at 트리거 적용
DROP TRIGGER IF EXISTS trigger_user_profiles_updated_at ON user_profiles;
CREATE TRIGGER trigger_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_community_categories_updated_at ON community_categories;
CREATE TRIGGER trigger_community_categories_updated_at
    BEFORE UPDATE ON community_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_community_posts_updated_at ON community_posts;
CREATE TRIGGER trigger_community_posts_updated_at
    BEFORE UPDATE ON community_posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_community_comments_updated_at ON community_comments;
CREATE TRIGGER trigger_community_comments_updated_at
    BEFORE UPDATE ON community_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 좋아요 카운트 업데이트 함수들
-- ============================================

-- 게시글 좋아요 카운트 업데이트 함수
CREATE OR REPLACE FUNCTION update_post_like_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE community_posts 
        SET like_count = like_count + 1 
        WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE community_posts 
        SET like_count = like_count - 1 
        WHERE id = OLD.post_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- 댓글 좋아요 카운트 업데이트 함수
CREATE OR REPLACE FUNCTION update_comment_like_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE community_comments 
        SET like_count = like_count + 1 
        WHERE id = NEW.comment_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE community_comments 
        SET like_count = like_count - 1 
        WHERE id = OLD.comment_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- 게시글 댓글 카운트 업데이트 함수
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE community_posts 
        SET comment_count = comment_count + 1 
        WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE community_posts 
        SET comment_count = comment_count - 1 
        WHERE id = OLD.post_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- ============================================
-- 트리거 생성
-- ============================================

-- 게시글 좋아요 트리거
DROP TRIGGER IF EXISTS trigger_post_like_count ON community_likes;
CREATE TRIGGER trigger_post_like_count
    AFTER INSERT OR DELETE ON community_likes
    FOR EACH ROW
    WHEN (NEW.post_id IS NOT NULL OR OLD.post_id IS NOT NULL)
    EXECUTE FUNCTION update_post_like_count();

-- 댓글 좋아요 트리거
DROP TRIGGER IF EXISTS trigger_comment_like_count ON community_likes;
CREATE TRIGGER trigger_comment_like_count
    AFTER INSERT OR DELETE ON community_likes
    FOR EACH ROW
    WHEN (NEW.comment_id IS NOT NULL OR OLD.comment_id IS NOT NULL)
    EXECUTE FUNCTION update_comment_like_count();

-- 게시글 댓글 카운트 트리거
DROP TRIGGER IF EXISTS trigger_post_comment_count ON community_comments;
CREATE TRIGGER trigger_post_comment_count
    AFTER INSERT OR DELETE ON community_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_post_comment_count();

-- ============================================
-- RLS (Row Level Security) 정책 설정
-- ============================================

-- user_profiles: 카카오 로그인 사용으로 인해 RLS 비활성화
-- ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Public profiles are viewable by everyone" ON user_profiles FOR SELECT USING (true);
-- CREATE POLICY "Users can insert own profile" ON user_profiles FOR INSERT WITH CHECK (auth.uid()::text = user_id);
-- CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (auth.uid()::text = user_id);
-- CREATE POLICY "Users can delete own profile" ON user_profiles FOR DELETE USING (auth.uid()::text = user_id);

-- community_categories: 모든 사용자가 읽기 가능, 관리자만 수정 가능
ALTER TABLE community_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Categories are viewable by everyone" ON community_categories FOR SELECT USING (true);

-- community_posts: 카카오 로그인 사용으로 인해 RLS 비활성화
-- ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Posts are viewable by everyone" ON community_posts FOR SELECT USING (is_deleted = false);
-- CREATE POLICY "Users can insert own posts" ON community_posts FOR INSERT WITH CHECK (auth.uid()::text = author_id);
-- CREATE POLICY "Users can update own posts" ON community_posts FOR UPDATE USING (auth.uid()::text = author_id);
-- CREATE POLICY "Users can delete own posts" ON community_posts FOR DELETE USING (auth.uid()::text = author_id);

-- community_comments: 카카오 로그인 사용으로 인해 RLS 비활성화
-- ALTER TABLE community_comments ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Comments are viewable by everyone" ON community_comments FOR SELECT USING (is_deleted = false);
-- CREATE POLICY "Users can insert own comments" ON community_comments FOR INSERT WITH CHECK (auth.uid()::text = author_id);
-- CREATE POLICY "Users can update own comments" ON community_comments FOR UPDATE USING (auth.uid()::text = author_id);
-- CREATE POLICY "Users can delete own comments" ON community_comments FOR DELETE USING (auth.uid()::text = author_id);

-- community_likes: 카카오 로그인 사용으로 인해 RLS 비활성화
-- ALTER TABLE community_likes ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Users can view all likes" ON community_likes FOR SELECT USING (true);
-- CREATE POLICY "Users can insert own likes" ON community_likes FOR INSERT WITH CHECK (auth.uid()::text = user_id);
-- CREATE POLICY "Users can delete own likes" ON community_likes FOR DELETE USING (auth.uid()::text = user_id);

-- notifications: 카카오 로그인 사용으로 인해 RLS 비활성화 (추후 필요시 활성화)
-- ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid()::text = recipient_id);
-- CREATE POLICY "System can insert notifications" ON notifications FOR INSERT WITH CHECK (true);
-- CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid()::text = recipient_id);
-- CREATE POLICY "Users can delete own notifications" ON notifications FOR DELETE USING (auth.uid()::text = recipient_id);

-- ============================================
-- 기본 카테고리 데이터 삽입
-- ============================================
INSERT INTO community_categories (name, slug, description, color, icon, display_order) VALUES
('전체', 'all', '모든 게시글', '#6366f1', 'all_inclusive', 0),
('자유게시판', 'free', '자유롭게 이야기해요', '#10b981', 'chat', 1),
('질문과 답변', 'qna', '궁금한 것을 물어보세요', '#f59e0b', 'help', 2),
('육아 팁', 'tips', '유용한 육아 정보를 공유해요', '#8b5cf6', 'lightbulb', 3),
('제품 리뷰', 'review', '육아용품 후기를 나누어요', '#ef4444', 'star', 4),
('일상 공유', 'daily', '아이와의 소중한 순간들', '#06b6d4', 'favorite', 5),
('인기글', 'popular', '인기 있는 게시글', '#f97316', 'trending_up', 6)
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- 테이블 설명 추가
-- ============================================
COMMENT ON TABLE user_profiles IS '사용자 프로필 정보를 저장하는 테이블';
COMMENT ON COLUMN user_profiles.id IS '프로필의 고유 식별자';
COMMENT ON COLUMN user_profiles.user_id IS '인증 사용자 ID (카카오 로그인 ID)';
COMMENT ON COLUMN user_profiles.nickname IS '사용자 닉네임 (커뮤니티에서 표시)';
COMMENT ON COLUMN user_profiles.profile_image_url IS '프로필 이미지 URL';
COMMENT ON COLUMN user_profiles.bio IS '사용자 소개글';
COMMENT ON COLUMN user_profiles.created_at IS '프로필 생성 시간';
COMMENT ON COLUMN user_profiles.updated_at IS '프로필 마지막 수정 시간';

COMMENT ON TABLE community_categories IS '커뮤니티 카테고리 정보';
COMMENT ON TABLE community_posts IS '커뮤니티 게시글';
COMMENT ON TABLE community_comments IS '커뮤니티 댓글';
COMMENT ON TABLE community_likes IS '게시글/댓글 좋아요';
COMMENT ON TABLE notifications IS '사용자 알림';

-- ============================================
-- 테이블 생성 확인
-- ============================================
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND (table_name LIKE 'community_%' 
         OR table_name = 'notifications'
         OR table_name = 'user_profiles')
ORDER BY table_name;