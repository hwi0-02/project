# 뽑기펫: 오늘뭐먹 위젯 - 스토어 출시 체크리스트

## ✅ 완료된 항목

### 기능 구현
- [x] 덱 알고리즘 (pop/refill)
- [x] 펫 레벨업 시스템 (15/30/60회 달성 아이템)
- [x] 7일 연속 달성 무지개 오라
- [x] Lazy Evaluation 일일 리셋
- [x] 홈 화면 위젯 (Android/iOS)
- [x] 위젯 ↔ 앱 동기화
- [x] 온보딩 플로우
- [x] 설정 화면

### 수익화
- [x] AdMob 배너 광고
- [x] AdMob 리워드 광고 (재뽑기 3회 이상)
- [x] RevenueCat IAP (프리미엄 평생 구독)
- [x] 프리미엄 유저 광고 제거

---

## 📋 출시 전 체크리스트

### 앱 메타데이터
- [ ] 앱 아이콘 (1024x1024) 제작
- [ ] 스플래시 화면 이미지
- [ ] 스토어 스크린샷 (6.5", 5.5", iPad)
- [ ] 프로모션 이미지
- [ ] 앱 설명 (한국어/영어)
- [ ] 키워드

### API 키 설정
- [ ] AdMob 실제 광고 Unit ID 설정
- [ ] RevenueCat API Key 설정
- [ ] App Groups ID 설정 (iOS)

### 법적 요구사항
- [ ] 개인정보처리방침 URL 준비
- [ ] 이용약관 URL 준비
- [ ] 앱 내 개인정보처리방침 링크 연결

### 테스트
- [ ] Android 위젯 테스트
- [ ] iOS 위젯 테스트
- [ ] 광고 표시 테스트
- [ ] IAP 구매/복원 테스트 (Sandbox)
- [ ] 일일 리셋 테스트
- [ ] 연속 달성 리셋 테스트

### 빌드 설정
- [ ] Android: build.gradle 버전 확인
- [ ] iOS: Info.plist 권한 설정
- [ ] iOS: Signing & Capabilities 확인
- [ ] Android: ProGuard 설정 (필요 시)

---

## 🚀 출시 절차

### Google Play Store
1. [ ] Play Console에서 앱 생성
2. [ ] 스토어 등록정보 입력
3. [ ] 콘텐츠 등급 설정
4. [ ] 앱 가격 및 배포 설정
5. [ ] AAB 파일 업로드
6. [ ] 내부 테스트 → 비공개 테스트 → 프로덕션

### Apple App Store
1. [ ] App Store Connect에서 앱 생성
2. [ ] App Information 입력
3. [ ] App Privacy 설정
4. [ ] 스크린샷 및 미리보기 업로드
5. [ ] IPA 업로드 (Xcode/Transporter)
6. [ ] TestFlight 테스트 → 앱 심사 제출

---

## 📝 참고 사항

### RevenueCat 설정
- Dashboard URL: https://app.revenuecat.com
- 제품 ID: `premium_lifetime`
- Entitlement ID: `premium`

### AdMob 설정
- Android 앱 ID: `ca-app-pub-XXXXXXXXXX~XXXXXXXXXX`
- iOS 앱 ID: `ca-app-pub-XXXXXXXXXX~XXXXXXXXXX`
- 배너 광고: `/banner`
- 리워드 광고: `/rewarded`

### 지원 연락처
- 이메일: support@fetchpet.app
- 개인정보처리방침: https://fetchpet.app/privacy
- 이용약관: https://fetchpet.app/terms
