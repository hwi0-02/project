# 뽑기펫: 오늘뭐먹 위젯 🐕

> 귀여운 펫이 오늘의 결정을 물어다 주는 앱

## 📱 소개

"오늘 뭐 먹지?", "오늘 운동 뭐 하지?" 매일 반복되는 고민!
뽑기펫이 대신 결정해 드려요!

### ✨ 주요 기능

- **🎯 덱 시스템**: 같은 항목이 연속으로 나오지 않는 공정한 뽑기
- **🐕 펫 육성**: 미션 완료할수록 펫이 레벨업하고 아이템 획득
- **📱 홈 위젯**: 앱을 열지 않아도 홈 화면에서 바로 뽑기
- **🔥 연속 달성**: 매일 미션을 완료하면 연속 달성 보너스
- **🌈 7일 달성 보상**: 7일 연속 달성 시 무지개 오라 획득

## 🛠 기술 스택

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Local Storage**: SharedPreferences
- **IAP**: RevenueCat (purchases_flutter)
- **Ads**: Google Mobile Ads (AdMob)
- **Widget**: home_widget

## 📂 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── src/
│   ├── constants/               # 상수 (색상, 문자열, 레벨)
│   ├── models/                  # 데이터 모델 (Deck, Pet, Streak)
│   ├── repositories/            # 데이터 레이어 (IAP 추상화)
│   ├── services/                # 비즈니스 로직 (광고, 리셋, 위젯동기화)
│   ├── providers/               # Riverpod Providers
│   ├── screens/                 # 화면 UI
│   ├── widgets/                 # 재사용 위젯
│   └── utils/                   # 유틸리티
```

## 🚀 시작하기

### 요구사항
- Flutter 3.10 이상
- Dart 3.0 이상

### 설치

```bash
# 의존성 설치
flutter pub get

# 개발 서버 실행
flutter run
```

### 빌드

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## ⚙️ 설정

### AdMob
`lib/src/services/ad_service.dart`에서 광고 Unit ID 설정:
```dart
static String get _bannerAdUnitId {
  // 실제 광고 ID로 교체
}
```

### RevenueCat
`lib/src/repositories/revenuecat_purchase_repository.dart`에서 API 키 설정:
```dart
static const String _apiKey = 'YOUR_REVENUECAT_API_KEY';
```

### iOS App Groups
`ios/FetchPetWidget/FetchPetWidget.entitlements`에서 App Group ID 설정

## 📋 라이선스

이 프로젝트는 개인 사용 목적으로 제작되었습니다.

## 👨‍💻 개발자

- Created with ❤️ by GitHub Copilot
