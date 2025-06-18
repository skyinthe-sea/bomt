-- 간단한 초대 코드 시스템을 위한 테이블 생성
CREATE TABLE IF NOT EXISTS simple_invites (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    code VARCHAR(6) NOT NULL UNIQUE,
    inviter_id VARCHAR(255) NOT NULL,
    baby_id UUID NOT NULL REFERENCES babies(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_by VARCHAR(255),
    used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_simple_invites_code ON simple_invites(code);
CREATE INDEX IF NOT EXISTS idx_simple_invites_inviter ON simple_invites(inviter_id);
CREATE INDEX IF NOT EXISTS idx_simple_invites_baby ON simple_invites(baby_id);
CREATE INDEX IF NOT EXISTS idx_simple_invites_active ON simple_invites(is_active, expires_at);

-- RLS (Row Level Security) 정책 설정
ALTER TABLE simple_invites ENABLE ROW LEVEL SECURITY;

-- 모든 인증된 사용자가 읽기/쓰기 가능 (간단한 정책)
CREATE POLICY "Enable all operations for authenticated users" ON simple_invites
    FOR ALL USING (auth.role() = 'authenticated');

-- 트리거 함수 생성 (updated_at 자동 업데이트)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 생성
CREATE TRIGGER update_simple_invites_updated_at 
    BEFORE UPDATE ON simple_invites 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();