# BabyMom 비밀번호 재설정 - Cloudflare Pages 배포 가이드

## 🌟 Cloudflare Pages 장점

- ✅ **완전 무료**: 월 500회 빌드, 무제한 대역폭
- ✅ **글로벌 CDN**: 전 세계 빠른 접속
- ✅ **자동 HTTPS**: SSL 인증서 자동 적용
- ✅ **커스텀 도메인**: 무료 도메인 연결 가능
- ✅ **Git 연동**: GitHub/GitLab 자동 배포

## 🚀 배포 방법

### 1. GitHub 저장소 준비

```bash
# 새 폴더 생성
mkdir babymom-password-reset
cd babymom-password-reset

# 필요한 파일들 복사
cp index.html .
cp _redirects .

# Git 초기화
git init
git add .
git commit -m "Add BabyMom password reset page for Cloudflare Pages"

# GitHub에 푸시
git remote add origin https://github.com/your-username/babymom-password-reset.git
git push -u origin main
```

### 2. Cloudflare Pages 배포

1. **Cloudflare 계정 생성**
   - [cloudflare.com](https://cloudflare.com) 회원가입

2. **Pages 프로젝트 생성**
   - Cloudflare 대시보드 → **Pages** 클릭
   - **Create a project** → **Connect to Git** 선택
   - GitHub 계정 연결 및 저장소 선택

3. **빌드 설정**
   ```
   Framework preset: None
   Build command: exit 0
   Build output directory: (비워두기)
   Root directory: (비워두기)
   ```

4. **배포 완료**
   - 자동으로 `https://your-project.pages.dev` URL 생성
   - 커스텀 도메인도 무료로 설정 가능

### 3. 대안: Direct Upload (Git 없이)

1. Cloudflare Pages → **Upload assets** 선택
2. `index.html`과 `_redirects` 파일 업로드
3. 즉시 배포 완료

## ⚙️ 설정 업데이트

### 1. Supabase 프로젝트 설정

```javascript
// index.html 파일에서 수정
const SUPABASE_URL = 'https://your-project-id.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
```

### 2. Supabase 대시보드 설정

1. **URL Configuration 설정**
   - [Supabase 대시보드](https://supabase.com/dashboard) 접속
   - **Authentication** → **URL Configuration**
   - **Additional redirect URLs**에 추가:
     ```
     https://your-project.pages.dev
     https://your-project.pages.dev/
     ```

### 3. Flutter 앱 코드 업데이트

```dart
// login_screen.dart에서 수정
final redirectUrl = 'https://your-project.pages.dev';
```

## 🔧 고급 설정 (선택사항)

### 커스텀 도메인 설정

1. Cloudflare Pages → **Custom domains**
2. **Set up a custom domain** 클릭
3. 도메인 입력 (예: `reset.babymom.com`)
4. DNS 설정 자동 완료

### 환경 변수 설정

```javascript
// 환경별 설정 분리
const config = {
  production: {
    SUPABASE_URL: 'https://prod-project.supabase.co',
    SUPABASE_ANON_KEY: 'prod-anon-key'
  },
  development: {
    SUPABASE_URL: 'https://dev-project.supabase.co', 
    SUPABASE_ANON_KEY: 'dev-anon-key'
  }
};

const isProduction = window.location.hostname !== 'localhost';
const currentConfig = isProduction ? config.production : config.development;
```

## 📱 Deep Link 설정

### iOS 설정 (ios/Runner/Info.plist)

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>babymom.auth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>babymom</string>
        </array>
    </dict>
</array>
```

### Android 설정 (android/app/src/main/AndroidManifest.xml)

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    
    <!-- 기존 intent-filter -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    
    <!-- Deep Link intent-filter 추가 -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="babymom" />
    </intent-filter>
</activity>
```

## 🧪 테스트 절차

1. **배포 확인**
   ```
   curl https://your-project.pages.dev
   # HTTP 200 응답 확인
   ```

2. **비밀번호 재설정 테스트**
   - 앱에서 "비밀번호를 잊으셨나요?" 클릭
   - 이메일 전송 확인
   - 이메일 링크 클릭하여 웹페이지 열림 확인
   - 새 비밀번호 설정 테스트

3. **Deep Link 테스트**
   - 웹페이지에서 비밀번호 변경 완료 후
   - 앱 자동 열림 확인 (모바일에서)

## 🔍 문제 해결

### "about:blank" 문제
- Supabase URL Configuration 확인
- 배포된 URL이 정확히 추가되었는지 확인

### 토큰 만료 에러
- 이메일 링크는 1시간 내 사용
- 새로운 재설정 요청 필요

### 앱이 열리지 않음
- Deep Link 설정 확인
- URL Scheme이 정확한지 확인
- 앱이 설치되어 있는지 확인

### Cloudflare Pages 빌드 실패
- `index.html` 파일 존재 확인
- Build command가 `exit 0`인지 확인
- 파일 크기가 25MB 이하인지 확인

## 📊 모니터링

### Cloudflare Analytics
- Pages 대시보드에서 접속 통계 확인
- 에러율 및 성능 모니터링

### Supabase 로그
- Auth 로그에서 비밀번호 재설정 요청 확인
- 실패한 요청 분석

## 💡 추가 최적화

### 성능 최적화
- CSS/JS 압축 (Cloudflare 자동 처리)
- 이미지 최적화 (필요시)
- 캐싱 설정 (자동 적용)

### 보안 강화
- CSP 헤더 설정 (Cloudflare Pages Functions 사용)
- Rate limiting (Cloudflare 방화벽 사용)

## 📝 참고 링크

- [Cloudflare Pages 문서](https://developers.cloudflare.com/pages/)
- [Supabase Auth 문서](https://supabase.com/docs/guides/auth)
- [Flutter Deep Link 가이드](https://docs.flutter.dev/development/ui/navigation/deep-linking)