-- Supabase Storage Bucket 생성을 위한 SQL 스크립트
-- 이 스크립트는 Supabase Dashboard의 SQL Editor에서 실행해야 합니다.

-- 1. community-images 버킷 생성
INSERT INTO storage.buckets (id, name, public)
VALUES ('community-images', 'community-images', true);

-- 2. 공개 읽기 정책 생성 (모든 사용자가 이미지를 볼 수 있도록)
CREATE POLICY "Public Access" ON storage.objects
FOR SELECT USING (bucket_id = 'community-images');

-- 3. 인증된 사용자 업로드 정책 생성
CREATE POLICY "Users can upload community images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'community-images' 
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = 'posts'
);

-- 4. 사용자가 자신의 이미지만 삭제할 수 있도록 하는 정책
CREATE POLICY "Users can delete own community images" ON storage.objects
FOR DELETE USING (
  bucket_id = 'community-images' 
  AND auth.role() = 'authenticated'
  AND (regexp_split_to_array((storage.filename(name)), '_'))[1] = auth.uid()::text
);

-- 5. 버킷이 성공적으로 생성되었는지 확인
SELECT * FROM storage.buckets WHERE id = 'community-images';