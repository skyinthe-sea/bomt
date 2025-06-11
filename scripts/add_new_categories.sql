-- ========================================
-- 새로운 커뮤니티 카테고리 추가 스크립트
-- ========================================

-- 기존 카테고리 확인
SELECT id, name, slug, color, icon, display_order, description 
FROM community_categories 
ORDER BY display_order;

-- ========================================
-- 새로운 카테고리 5개 추가
-- ========================================

-- 1. 수면문제 카테고리 추가
INSERT INTO community_categories (
    name, 
    slug, 
    description, 
    color, 
    icon, 
    display_order, 
    is_active, 
    created_at, 
    updated_at
) VALUES (
    '수면문제',
    'sleep_issues',
    '수면 패턴, 잠자리 습관 등 수면 관련 고민을 나누세요',
    '#8B5CF6',
    'bedtime',
    10,
    true,
    NOW(),
    NOW()
);

-- 2. 이유식 카테고리 추가
INSERT INTO community_categories (
    name, 
    slug, 
    description, 
    color, 
    icon, 
    display_order, 
    is_active, 
    created_at, 
    updated_at
) VALUES (
    '이유식',
    'baby_food',
    '이유식 레시피, 식재료, 먹이는 방법 등을 공유하세요',
    '#10B981',
    'restaurant',
    11,
    true,
    NOW(),
    NOW()
);

-- 3. 발달단계 카테고리 추가
INSERT INTO community_categories (
    name, 
    slug, 
    description, 
    color, 
    icon, 
    display_order, 
    is_active, 
    created_at, 
    updated_at
) VALUES (
    '발달단계',
    'development',
    '월령별 발달 과정, 성장 이정표 등을 함께 확인해요',
    '#F59E0B',
    'toys',
    12,
    true,
    NOW(),
    NOW()
);

-- 4. 예방접종 카테고리 추가
INSERT INTO community_categories (
    name, 
    slug, 
    description, 
    color, 
    icon, 
    display_order, 
    is_active, 
    created_at, 
    updated_at
) VALUES (
    '예방접종',
    'vaccination',
    '예방접종 일정, 후관리, 부작용 등 정보를 나누세요',
    '#3B82F6',
    'vaccines',
    13,
    true,
    NOW(),
    NOW()
);

-- 5. 산후회복 카테고리 추가
INSERT INTO community_categories (
    name, 
    slug, 
    description, 
    color, 
    icon, 
    display_order, 
    is_active, 
    created_at, 
    updated_at
) VALUES (
    '산후회복',
    'postpartum',
    '산후조리, 회복 과정, 몸과 마음 관리를 함께해요',
    '#EC4899',
    'self_care',
    14,
    true,
    NOW(),
    NOW()
);

-- ========================================
-- 추가 후 확인
-- ========================================

-- 모든 카테고리 조회 (정렬 순서대로)
SELECT 
    id, 
    name, 
    slug, 
    description, 
    color, 
    icon, 
    display_order, 
    is_active,
    created_at
FROM community_categories 
WHERE is_active = true
ORDER BY display_order;

-- ========================================
-- 중복 제거 (만약 필요한 경우)
-- ========================================

-- 혹시 중복된 slug가 있다면 제거
-- DELETE FROM community_categories 
-- WHERE slug IN ('sleep_issues', 'baby_food', 'development', 'vaccination', 'postpartum')
-- AND created_at < (최신 생성 시간);