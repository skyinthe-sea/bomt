-- ============================================
-- 사용자 안전 기능 데이터베이스 스키마
-- App Store Guideline 1.2 준수를 위한 테이블 설계
-- ============================================

-- 1. EULA (이용약관) 버전 관리 테이블
CREATE TABLE IF NOT EXISTS user_agreement_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version_code VARCHAR(20) NOT NULL UNIQUE, -- 예: "1.0.0", "1.1.0"
    title JSONB NOT NULL, -- 다국어 제목 {"ko": "이용약관", "en": "Terms of Service"}
    content JSONB NOT NULL, -- 다국어 내용
    agreement_type VARCHAR(50) NOT NULL DEFAULT 'terms_of_service', -- terms_of_service, privacy_policy, community_guidelines
    is_mandatory BOOLEAN NOT NULL DEFAULT true, -- 필수 동의 여부
    is_active BOOLEAN NOT NULL DEFAULT true,
    effective_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 사용자별 약관 동의 이력 테이블
CREATE TABLE IF NOT EXISTS user_agreement_consents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    agreement_version_id UUID NOT NULL REFERENCES user_agreement_versions(id) ON DELETE CASCADE,
    consented_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    ip_address INET, -- 동의 시점 IP (법적 증거)
    user_agent TEXT, -- 동의 시점 사용자 에이전트
    is_withdrawn BOOLEAN NOT NULL DEFAULT false,
    withdrawn_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(user_id, agreement_version_id)
);

-- 3. 사용자 차단 관계 테이블
CREATE TABLE IF NOT EXISTS user_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    blocked_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reason VARCHAR(100), -- 차단 이유
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- 자기 자신을 차단할 수 없음
    CONSTRAINT check_not_self_block CHECK (blocker_user_id != blocked_user_id),
    -- 중복 차단 방지
    UNIQUE(blocker_user_id, blocked_user_id)
);

-- 4. 신고 시스템 테이블
CREATE TABLE IF NOT EXISTS content_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reported_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content_type VARCHAR(50) NOT NULL, -- 'post', 'comment'
    content_id UUID NOT NULL, -- community_posts.id 또는 community_comments.id
    report_reason VARCHAR(50) NOT NULL, -- 'harassment', 'spam', 'inappropriate_content', 'hate_speech', 'violence', 'other'
    report_description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- 'pending', 'reviewing', 'resolved', 'dismissed'
    admin_notes TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- 중복 신고 방지 (같은 사용자가 같은 콘텐츠를 중복 신고할 수 없음)
    UNIQUE(reporter_user_id, content_type, content_id)
);

-- 5. 관리자 액션 로그 테이블
CREATE TABLE IF NOT EXISTS admin_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL, -- 'warning', 'temporary_ban', 'permanent_ban', 'content_removal'
    target_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    target_content_type VARCHAR(50), -- 'post', 'comment'
    target_content_id UUID,
    related_report_id UUID REFERENCES content_reports(id),
    reason TEXT NOT NULL,
    duration_days INTEGER, -- 임시 정지인 경우 기간
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 인덱스 생성 (성능 최적화)
-- ============================================

-- 약관 동의 조회 최적화
CREATE INDEX IF NOT EXISTS idx_user_agreement_consents_user_id 
    ON user_agreement_consents(user_id);
CREATE INDEX IF NOT EXISTS idx_user_agreement_consents_agreement_version 
    ON user_agreement_consents(agreement_version_id);

-- 사용자 차단 조회 최적화
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocker 
    ON user_blocks(blocker_user_id);
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocked 
    ON user_blocks(blocked_user_id);

-- 신고 시스템 조회 최적화
CREATE INDEX IF NOT EXISTS idx_content_reports_reporter 
    ON content_reports(reporter_user_id);
CREATE INDEX IF NOT EXISTS idx_content_reports_reported 
    ON content_reports(reported_user_id);
CREATE INDEX IF NOT EXISTS idx_content_reports_content 
    ON content_reports(content_type, content_id);
CREATE INDEX IF NOT EXISTS idx_content_reports_status 
    ON content_reports(status);

-- ============================================
-- RLS (Row Level Security) 정책
-- ============================================

-- 약관 버전 - 누구나 읽기 가능
ALTER TABLE user_agreement_versions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read active agreement versions" ON user_agreement_versions
    FOR SELECT USING (is_active = true);

-- 사용자 약관 동의 - 본인 데이터만 조회/수정 가능
ALTER TABLE user_agreement_consents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own consents" ON user_agreement_consents
    FOR ALL USING (auth.uid() = user_id);

-- 사용자 차단 - 본인이 한 차단만 관리 가능
ALTER TABLE user_blocks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own blocks" ON user_blocks
    FOR ALL USING (auth.uid() = blocker_user_id);

-- 신고 시스템 - 본인이 한 신고만 조회 가능
ALTER TABLE content_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own reports" ON content_reports
    FOR SELECT USING (auth.uid() = reporter_user_id);
CREATE POLICY "Users can create reports" ON content_reports
    FOR INSERT WITH CHECK (auth.uid() = reporter_user_id);

-- 관리자 액션 로그 - 관리자만 접근 가능
ALTER TABLE admin_actions ENABLE ROW LEVEL SECURITY;
-- 관리자 정책은 별도로 구현 예정

-- ============================================
-- 기본 데이터 삽입
-- ============================================

-- 기본 이용약관 버전 삽입
INSERT INTO user_agreement_versions (version_code, title, content, agreement_type, is_mandatory, effective_date) VALUES 
('1.0.0', 
 '{"ko": "이용약관", "en": "Terms of Service", "ja": "利用規約"}',
 '{"ko": "BabyMom 이용약관\n\n제1조 (목적)\n본 약관은 사용자 생성 콘텐츠에 대한 정책을 포함하여, 모든 사용자가 안전하고 건전한 환경에서 서비스를 이용할 수 있도록 합니다.\n\n제2조 (사용자 생성 콘텐츠)\n1. 사용자는 다른 사용자에게 해로운, 위협적인, 불법적인, 중상모략하는, 음란한, 모독적인, 또는 기타 부적절한 내용을 게시할 수 없습니다.\n2. 회사는 부적절한 콘텐츠 및 남용 사용자에 대해 무관용 정책을 적용합니다.\n3. 위반 시 사전 통보 없이 계정이 정지되거나 삭제될 수 있습니다.\n\n제3조 (신고 및 차단)\n1. 사용자는 부적절한 콘텐츠나 행위를 신고할 수 있습니다.\n2. 사용자는 다른 사용자를 차단할 수 있는 기능을 제공받습니다.", "en": "BabyMom Terms of Service\n\nArticle 1 (Purpose)\nThese terms include policies for user-generated content to ensure all users can use the service in a safe and healthy environment.\n\nArticle 2 (User-Generated Content)\n1. Users cannot post content that is harmful, threatening, illegal, defamatory, obscene, abusive, or otherwise objectionable to other users.\n2. The company applies a zero-tolerance policy for objectionable content and abusive users.\n3. Accounts may be suspended or deleted without prior notice for violations.\n\nArticle 3 (Reporting and Blocking)\n1. Users can report inappropriate content or behavior.\n2. Users are provided with the ability to block other users.", "ja": "BabyMom 利用規約\n\n第1条（目的）\n本規約は、ユーザー生成コンテンツに関するポリシーを含み、すべてのユーザーが安全で健全な環境でサービスを利用できるようにします。\n\n第2条（ユーザー生成コンテンツ）\n1. ユーザーは、他のユーザーに有害、脅迫的、違法、中傷的、わいせつ、虐待的、またはその他不適切なコンテンツを投稿できません。\n2. 当社は不適切なコンテンツと悪用ユーザーに対してゼロトレランス・ポリシーを適用します。\n3. 違反時は事前通知なしにアカウントが停止または削除される場合があります。\n\n第3条（報告とブロック）\n1. ユーザーは不適切なコンテンツや行為を報告できます。\n2. ユーザーには他のユーザーをブロックする機能が提供されます。"}',
 'terms_of_service', 
 true,
 NOW());

-- 커뮤니티 가이드라인 삽입
INSERT INTO user_agreement_versions (version_code, title, content, agreement_type, is_mandatory, effective_date) VALUES 
('1.0.0',
 '{"ko": "커뮤니티 가이드라인", "en": "Community Guidelines", "ja": "コミュニティガイドライン"}',
 '{"ko": "BabyMom 커뮤니티 가이드라인\n\n1. 서로를 존중하세요\n- 다른 사용자를 괴롭히거나 위협하지 마세요\n- 개인정보를 무단으로 공유하지 마세요\n\n2. 부적절한 콘텐츠 금지\n- 스팸, 광고, 혐오 발언 금지\n- 음란물, 폭력적 콘텐츠 금지\n- 허위 정보 유포 금지\n\n3. 신고 및 차단 시스템\n- 부적절한 내용을 발견하면 신고해 주세요\n- 불편한 사용자는 차단할 수 있습니다\n\n4. 위반 시 조치\n- 경고, 임시 정지, 영구 정지 등의 조치가 취해질 수 있습니다", "en": "BabyMom Community Guidelines\n\n1. Respect Each Other\n- Do not harass or threaten other users\n- Do not share personal information without permission\n\n2. Prohibited Content\n- No spam, advertisements, or hate speech\n- No obscene or violent content\n- No spreading of false information\n\n3. Reporting and Blocking System\n- Please report inappropriate content when found\n- You can block users who make you uncomfortable\n\n4. Actions for Violations\n- Warnings, temporary suspensions, or permanent bans may be applied", "ja": "BabyMom コミュニティガイドライン\n\n1. お互いを尊重しましょう\n- 他のユーザーを嫌がらせしたり脅かしたりしないでください\n- 個人情報を無断で共有しないでください\n\n2. 不適切なコンテンツの禁止\n- スパム、広告、ヘイトスピーチの禁止\n- わいせつ物、暴力的コンテンツの禁止\n- 虚偽情報の拡散禁止\n\n3. 報告とブロックシステム\n- 不適切なコンテンツを発見したら報告してください\n- 不快なユーザーをブロックできます\n\n4. 違反時の措置\n- 警告、一時停止、永久停止などの措置が取られる場合があります"}',
 'community_guidelines',
 true,
 NOW());

-- ============================================
-- 트리거 함수 (updated_at 자동 업데이트)
-- ============================================

-- updated_at 자동 업데이트 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 적용
CREATE TRIGGER update_user_agreement_versions_updated_at 
    BEFORE UPDATE ON user_agreement_versions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_content_reports_updated_at 
    BEFORE UPDATE ON content_reports 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();