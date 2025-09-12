-- ============================================
-- content_reports 테이블 외래키 수정
-- user_profiles와의 조인을 위한 외래키 관계 설정
-- ============================================

-- 기존 외래키 제약 조건 제거
ALTER TABLE content_reports 
DROP CONSTRAINT IF EXISTS content_reports_reporter_user_id_fkey;

ALTER TABLE content_reports 
DROP CONSTRAINT IF EXISTS content_reports_reported_user_id_fkey;

-- user_profiles를 참조하는 새로운 외래키 제약 조건 추가
ALTER TABLE content_reports 
ADD CONSTRAINT content_reports_reporter_user_id_fkey 
FOREIGN KEY (reporter_user_id) REFERENCES user_profiles(id) ON DELETE CASCADE;

ALTER TABLE content_reports 
ADD CONSTRAINT content_reports_reported_user_id_fkey 
FOREIGN KEY (reported_user_id) REFERENCES user_profiles(id) ON DELETE CASCADE;

-- 성공 메시지
DO $$
BEGIN
  RAISE NOTICE '✅ content_reports 외래키 관계가 user_profiles로 수정되었습니다.';
END $$;