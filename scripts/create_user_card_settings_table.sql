-- 카드 설정 테이블 생성 SQL
-- Supabase 대시보드에서 SQL Editor를 통해 실행하세요

-- 1. user_card_settings 테이블 생성
CREATE TABLE IF NOT EXISTS user_card_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    card_type TEXT NOT NULL,
    is_visible BOOLEAN NOT NULL DEFAULT true,
    display_order INTEGER NOT NULL DEFAULT 0,
    custom_settings JSONB DEFAULT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- 복합 인덱스: 한 사용자당 카드 타입은 유일해야 함
    UNIQUE(user_id, card_type)
);

-- 2. 인덱스 생성 (성능 최적화)
CREATE INDEX IF NOT EXISTS idx_user_card_settings_user_id 
ON user_card_settings(user_id);

CREATE INDEX IF NOT EXISTS idx_user_card_settings_card_type 
ON user_card_settings(card_type);

CREATE INDEX IF NOT EXISTS idx_user_card_settings_display_order 
ON user_card_settings(user_id, display_order);

CREATE INDEX IF NOT EXISTS idx_user_card_settings_is_visible 
ON user_card_settings(user_id, is_visible);

-- 3. updated_at 자동 업데이트 트리거 함수 (존재하지 않는 경우에만 생성)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- 4. updated_at 트리거 설정
DROP TRIGGER IF EXISTS trigger_user_card_settings_updated_at ON user_card_settings;
CREATE TRIGGER trigger_user_card_settings_updated_at
    BEFORE UPDATE ON user_card_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 5. RLS (Row Level Security) 정책 설정
ALTER TABLE user_card_settings ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 카드 설정만 조회 가능
CREATE POLICY "Users can view own card settings" ON user_card_settings
    FOR SELECT USING (auth.uid()::text = user_id);

-- 사용자는 자신의 카드 설정만 삽입 가능
CREATE POLICY "Users can insert own card settings" ON user_card_settings
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

-- 사용자는 자신의 카드 설정만 업데이트 가능
CREATE POLICY "Users can update own card settings" ON user_card_settings
    FOR UPDATE USING (auth.uid()::text = user_id);

-- 사용자는 자신의 카드 설정만 삭제 가능
CREATE POLICY "Users can delete own card settings" ON user_card_settings
    FOR DELETE USING (auth.uid()::text = user_id);

-- 6. 기본 카드 설정 데이터 삽입 함수
CREATE OR REPLACE FUNCTION initialize_user_card_settings(p_user_id TEXT)
RETURNS VOID AS $$
DECLARE
    card_types TEXT[] := ARRAY['feeding', 'sleep', 'diaper', 'solid_food', 'medication', 'milk_pumping'];
    card_type TEXT;
    i INTEGER := 0;
BEGIN
    FOREACH card_type IN ARRAY card_types
    LOOP
        INSERT INTO user_card_settings (user_id, card_type, is_visible, display_order)
        VALUES (p_user_id, card_type, true, i)
        ON CONFLICT (user_id, card_type) DO NOTHING;
        
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 7. 테이블 및 함수에 대한 설명 추가
COMMENT ON TABLE user_card_settings IS '사용자별 홈 화면 카드 설정을 저장하는 테이블';
COMMENT ON COLUMN user_card_settings.id IS '카드 설정의 고유 식별자';
COMMENT ON COLUMN user_card_settings.user_id IS '카카오 로그인 사용자 ID';
COMMENT ON COLUMN user_card_settings.card_type IS '카드 타입 (feeding, sleep, diaper, etc.)';
COMMENT ON COLUMN user_card_settings.is_visible IS '카드 표시 여부';
COMMENT ON COLUMN user_card_settings.display_order IS '카드 표시 순서 (0부터 시작)';
COMMENT ON COLUMN user_card_settings.custom_settings IS '카드별 사용자 정의 설정 (JSON)';
COMMENT ON COLUMN user_card_settings.created_at IS '설정 생성 시간';
COMMENT ON COLUMN user_card_settings.updated_at IS '설정 마지막 수정 시간';

COMMENT ON FUNCTION initialize_user_card_settings(TEXT) IS '새 사용자를 위한 기본 카드 설정을 초기화하는 함수';

-- 8. 테이블 상태 확인 쿼리 (옵션)
-- SELECT 
--     schemaname,
--     tablename,
--     attname as column_name,
--     typname as data_type,
--     not attnotnull as nullable
-- FROM pg_attribute 
-- JOIN pg_class ON pg_class.oid = pg_attribute.attrelid 
-- JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace 
-- JOIN pg_type ON pg_type.oid = pg_attribute.atttypid 
-- WHERE pg_class.relname = 'user_card_settings' 
--     AND pg_namespace.nspname = 'public'
--     AND attnum > 0 
-- ORDER BY attnum;