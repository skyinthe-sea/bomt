-- ============================================
-- EULA 업데이트: 24시간 대응 정책 및 개발자 연락처 추가
-- App Store Guideline 1.2 준수를 위한 업데이트
-- ============================================

-- 기존 이용약관 버전을 비활성화하고 새 버전 추가
UPDATE user_agreement_versions 
SET is_active = false, updated_at = NOW()
WHERE version_code = '1.0.0' AND agreement_type = 'terms_of_service';

-- 새로운 이용약관 버전 추가 (24시간 대응 정책 포함)
INSERT INTO user_agreement_versions (version_code, title, content, agreement_type, is_mandatory, effective_date) VALUES 
('1.1.0', 
 '{"ko": "이용약관", "en": "Terms of Service", "ja": "利用規約"}',
 '{"ko": "BabyMom 이용약관 (v1.1.0)\n\n제1조 (목적)\n본 약관은 사용자 생성 콘텐츠에 대한 정책을 포함하여, 모든 사용자가 안전하고 건전한 환경에서 서비스를 이용할 수 있도록 합니다.\n\n제2조 (사용자 생성 콘텐츠)\n1. 사용자는 다른 사용자에게 해로운, 위협적인, 불법적인, 중상모략하는, 음란한, 모독적인, 또는 기타 부적절한 내용을 게시할 수 없습니다.\n2. 회사는 부적절한 콘텐츠 및 남용 사용자에 대해 무관용 정책을 적용합니다.\n3. 위반 시 사전 통보 없이 계정이 정지되거나 삭제될 수 있습니다.\n4. 회사는 자동화된 콘텐츠 필터링 시스템을 운영하여 부적절한 내용이 게시되는 것을 사전에 방지합니다.\n\n제3조 (신고 및 차단 시스템)\n1. 사용자는 부적절한 콘텐츠나 행위를 신고할 수 있습니다.\n2. 사용자는 다른 사용자를 차단할 수 있는 기능을 제공받습니다.\n3. 회사는 모든 신고를 24시간 내에 검토하고 적절한 조치를 취합니다.\n4. 긴급한 경우 즉시 대응하며, 필요시 관련 콘텐츠를 임시 제한할 수 있습니다.\n5. 신고 처리 결과는 신고자에게 통지됩니다.\n\n제4조 (개발자 연락처)\n부적절한 콘텐츠 신고나 문의사항이 있으시면 다음 방법으로 연락해주세요:\n- 앱 내: 설정 → 도움말 → 개발자에게 연락하기\n- 이메일: support@babymom.app\n- 응답시간: 영업일 기준 24시간 이내", "en": "BabyMom Terms of Service (v1.1.0)\n\nArticle 1 (Purpose)\nThese terms include policies for user-generated content to ensure all users can use the service in a safe and healthy environment.\n\nArticle 2 (User-Generated Content)\n1. Users cannot post content that is harmful, threatening, illegal, defamatory, obscene, abusive, or otherwise objectionable to other users.\n2. The company applies a zero-tolerance policy for objectionable content and abusive users.\n3. Accounts may be suspended or deleted without prior notice for violations.\n4. The company operates automated content filtering systems to prevent inappropriate content from being posted.\n\nArticle 3 (Reporting and Blocking System)\n1. Users can report inappropriate content or behavior.\n2. Users are provided with the ability to block other users.\n3. The company will review all reports within 24 hours and take appropriate action.\n4. In urgent cases, we respond immediately and may temporarily restrict relevant content if necessary.\n5. Report processing results will be notified to the reporter.\n\nArticle 4 (Developer Contact Information)\nFor reporting inappropriate content or inquiries, please contact us through:\n- In-app: Settings → Help → Contact Developer\n- Email: support@babymom.app\n- Response time: Within 24 hours on business days", "ja": "BabyMom 利用規約 (v1.1.0)\n\n第1条（目的）\n本規約は、ユーザー生成コンテンツに関するポリシーを含み、すべてのユーザーが安全で健全な環境でサービスを利用できるようにします。\n\n第2条（ユーザー生成コンテンツ）\n1. ユーザーは、他のユーザーに有害、脅迫的、違法、中傷的、わいせつ、虐待的、またはその他不適切なコンテンツを投稿できません。\n2. 当社は不適切なコンテンツと悪用ユーザーに対してゼロトレランス・ポリシーを適用します。\n3. 違反時は事前通知なしにアカウントが停止または削除される場合があります。\n4. 当社は自動化されたコンテンツフィルタリングシステムを運用し、不適切なコンテンツの投稿を事前に防止します。\n\n第3条（報告とブロックシステム）\n1. ユーザーは不適切なコンテンツや行為を報告できます。\n2. ユーザーには他のユーザーをブロックする機能が提供されます。\n3. 当社はすべての報告を24時間以内に審査し、適切な措置を講じます。\n4. 緊急の場合は即座に対応し、必要に応じて関連コンテンツを一時的に制限することがあります。\n5. 報告処理結果は報告者に通知されます。\n\n第4条（開発者連絡先情報）\n不適切なコンテンツの報告や問い合わせについては、以下の方法でお問い合わせください：\n- アプリ内：設定 → ヘルプ → 開発者に連絡する\n- メール：support@babymom.app\n- 応答時間：営業日24時間以内"}',
 'terms_of_service', 
 true,
 NOW());

-- 기존 커뮤니티 가이드라인도 업데이트
UPDATE user_agreement_versions 
SET is_active = false, updated_at = NOW()
WHERE version_code = '1.0.0' AND agreement_type = 'community_guidelines';

-- 새로운 커뮤니티 가이드라인 버전 추가
INSERT INTO user_agreement_versions (version_code, title, content, agreement_type, is_mandatory, effective_date) VALUES 
('1.1.0',
 '{"ko": "커뮤니티 가이드라인", "en": "Community Guidelines", "ja": "コミュニティガイドライン"}',
 '{"ko": "BabyMom 커뮤니티 가이드라인 (v1.1.0)\n\n1. 서로를 존중하세요\n- 다른 사용자를 괴롭히거나 위협하지 마세요\n- 개인정보를 무단으로 공유하지 마세요\n- 모든 사용자가 환영받는 환경을 만들어주세요\n\n2. 부적절한 콘텐츠 금지\n- 스팸, 광고, 혐오 발언 금지\n- 음란물, 폭력적 콘텐츠 금지\n- 허위 정보 유포 금지\n- 자동 필터링 시스템이 의심 콘텐츠를 사전 차단합니다\n\n3. 신고 및 차단 시스템\n- 부적절한 내용을 발견하면 즉시 신고해 주세요\n- 불편한 사용자는 차단할 수 있습니다\n- 모든 신고는 24시간 내에 처리됩니다\n- 허위 신고 시 제재를 받을 수 있습니다\n\n4. 위반 시 조치\n- 1차: 경고 및 콘텐츠 삭제\n- 2차: 임시 정지 (1-7일)\n- 3차: 영구 정지\n- 심각한 위반 시 즉시 영구 정지\n\n5. 문의 및 이의제기\n- 처리 결과에 문의가 있으면 언제든 연락하세요\n- 설정 → 도움말 → 개발자에게 연락하기\n- support@babymom.app", "en": "BabyMom Community Guidelines (v1.1.0)\n\n1. Respect Each Other\n- Do not harass or threaten other users\n- Do not share personal information without permission\n- Create a welcoming environment for all users\n\n2. Prohibited Content\n- No spam, advertisements, or hate speech\n- No obscene or violent content\n- No spreading of false information\n- Automated filtering systems proactively block suspicious content\n\n3. Reporting and Blocking System\n- Please report inappropriate content immediately when found\n- You can block users who make you uncomfortable\n- All reports are processed within 24 hours\n- False reporting may result in penalties\n\n4. Actions for Violations\n- 1st: Warning and content removal\n- 2nd: Temporary suspension (1-7 days)\n- 3rd: Permanent ban\n- Immediate permanent ban for serious violations\n\n5. Inquiries and Appeals\n- Contact us anytime if you have questions about processing results\n- Settings → Help → Contact Developer\n- support@babymom.app", "ja": "BabyMom コミュニティガイドライン (v1.1.0)\n\n1. お互いを尊重しましょう\n- 他のユーザーを嫌がらせしたり脅かしたりしないでください\n- 個人情報を無断で共有しないでください\n- すべてのユーザーが歓迎される環境を作りましょう\n\n2. 不適切なコンテンツの禁止\n- スパム、広告、ヘイトスピーチの禁止\n- わいせつ物、暴力的コンテンツの禁止\n- 虚偽情報の拡散禁止\n- 自動フィルタリングシステムが疑わしいコンテンツを事前にブロックします\n\n3. 報告とブロックシステム\n- 不適切なコンテンツを発見したらすぐに報告してください\n- 不快なユーザーをブロックできます\n- すべての報告は24時間以内に処理されます\n- 虚偽の報告は制裁を受ける可能性があります\n\n4. 違反時の措置\n- 1回目：警告とコンテンツ削除\n- 2回目：一時停止（1-7日）\n- 3回目：永久停止\n- 深刻な違反の場合は即座に永久停止\n\n5. 問い合わせと異議申し立て\n- 処理結果について質問がある場合はいつでもお問い合わせください\n- 設定 → ヘルプ → 開発者に連絡する\n- support@babymom.app"}',
 'community_guidelines',
 true,
 NOW());

-- 성공 메시지
DO $$
BEGIN
  RAISE NOTICE '✅ EULA 및 커뮤니티 가이드라인이 v1.1.0으로 업데이트되었습니다.';
  RAISE NOTICE '📋 추가된 내용:';
  RAISE NOTICE '   - 24시간 내 신고 처리 약속';
  RAISE NOTICE '   - 자동 콘텐츠 필터링 시스템 명시';
  RAISE NOTICE '   - 개발자 연락처 정보 (support@babymom.app)';
  RAISE NOTICE '   - 상세한 위반 시 조치 가이드라인';
END $$;