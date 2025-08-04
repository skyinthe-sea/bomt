# BabyMom 비밀번호 재설정 웹페이지 배포 가이드

## 🚀 빠른 배포 방법

### 1. Vercel에 배포 (추천)

1. **GitHub 저장소 생성**
   ```bash
   # 새 폴더 생성
   mkdir babymom-password-reset
   cd babymom-password-reset
   
   # 파일 복사
   cp password-reset.html index.html
   cp vercel.json .
   
   # Git 초기화
   git init
   git add .
   git commit -m "Add password reset page"
   ```

2. **Vercel 배포**
   - [vercel.com](https://vercel.com)에서 회원가입
   - "New Project" 클릭
   - GitHub 저장소 연결
   - 자동 배포 완료!

### 2. 대안: GitHub Pages

```bash
# GitHub Pages용 간단 설정
echo "password-reset.html을 index.html로 이름 변경 후 GitHub Pages 활성화"
```

## ⚙️ Supabase 설정

### 1. 대시보드 설정

1. **Supabase 대시보드 접속**
   - [supabase.com/dashboard](https://supabase.com/dashboard)
   - 프로젝트 선택

2. **URL 구성 설정**
   - **Authentication** → **URL Configuration** 이동
   - **Additional redirect URLs**에 배포된 URL 추가:
     ```
     https://your-vercel-url.vercel.app
     https://your-vercel-url.vercel.app/
     ```

### 2. 코드 업데이트

`password-reset.html` 파일에서 다음 부분 수정:

```javascript
// 실제 Supabase 프로젝트 정보로 변경
const SUPABASE_URL = 'https://your-project-id.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
```

## 🔧 앱 코드 업데이트

배포된 URL로 `login_screen.dart` 업데이트:

```dart
final redirectUrl = 'https://your-actual-vercel-url.vercel.app';
```

## 📱 Deep Link 설정 (선택사항)

### iOS (ios/Runner/Info.plist)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>babymom.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>babymom</string>
        </array>
    </dict>
</array>
```

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="babymom" />
</intent-filter>
```

## 🧪 테스트 방법

1. **비밀번호 재설정 요청**
   - 앱에서 "비밀번호를 잊으셨나요?" 클릭
   - 이메일 입력 후 전송

2. **이메일 확인**
   - 받은 이메일에서 "Reset Password" 클릭
   - 웹페이지가 정상적으로 열리는지 확인

3. **비밀번호 변경**
   - 새 비밀번호 입력
   - 성공 메시지 확인

## 🔍 문제 해결

### about:blank 페이지로 가는 경우
- Supabase URL Configuration에서 redirect URL이 제대로 설정되었는지 확인
- 배포된 웹페이지 URL이 정확한지 확인

### 토큰 만료 에러
- 이메일 링크는 1시간 내에 사용해야 함
- 새로운 비밀번호 재설정 요청 필요

### 웹페이지가 열리지 않는 경우
- 배포 상태 확인
- CORS 설정 확인
- 네트워크 연결 확인

## 📝 참고사항

- 웹페이지는 HTTPS로 배포되어야 함
- Supabase 프로젝트의 Site URL과 Additional redirect URLs 모두 설정 필요
- 모바일 앱의 deep link 설정은 선택사항이지만 사용자 경험 향상에 도움됨