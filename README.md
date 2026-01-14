# flutter_practice_base

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 폴더 구조 (lib/ 기준)

```
lib/
├─ main.dart
│
├─ app/
│  ├─ app.dart
│  ├─ bootstrap.dart
│  │
│  ├─ di/
│  │  └─ app_scope.dart
│  │
│  └─ router/
│     ├─ app_router.dart
│     ├─ app_routes.dart
│     ├─ session_gate.dart
│     ├─ session_gate_dummy.dart
│     └─ _internal/
│        └─ route_utility.dart
│
├─ core/
│  ├─ auth/
│  │  ├─ token_storage.dart
│  │  └─ session_events.dart
│  │
│  ├─ network/
│  │  ├─ dio_client.dart
│  │  └─ interceptors/
│  │     ├─ auth_interceptor.dart
│  │     └─ logging_interceptor.dart
│  │
│  ├─ error/
│  │  ├─ app_exception.dart
│  │  └─ error_mapper.dart
│  │
│  └─ utils/
│     ├─ logger.dart
│     └─ debouncer.dart
│
└─ features/
   ├─ splash/
   │  ├─ 1_domain/
   │  ├─ 2_data/
   │  ├─ 3_state/
   │  ├─ 4_page/
   │  │  └─ splash_page.dart
   │  └─ 5_sub_widgets/
   │
   ├─ dashboard/
   │  ├─ 1_domain/
   │  ├─ 2_data/
   │  ├─ 3_state/
   │  ├─ 4_page/
   │  │  └─ dashboard_page.dart
   │  ├─ 5_sub_widgets/
   │  │
   │  ├─ home/
   │  │  ├─ 1_domain/
   │  │  ...
   │  │
   │  ├─ settings/
   │  │  ├─ 1_domain/
   │  │  ...
   │  ...
   ├─ common_widgets/
   │  ├─ exam_widgets_1/
   │  │  ├─ 1_domain/
   │  │  ├─ 2_data/
   │  │  ├─ 3_state/
   │  │  ├─ 4_page/
   │  │  └─ 5_sub_widgets/
   │  └─ exam_func_2/
   │     ...
   ...
```

간단한 설명
- **app**: 앱 진입점, 라우터, DI 등 앱 레벨 구성.
- **core**: 네트워크, 인증, 에러, 유틸 등 재사용 가능한 공통 모듈.
- **features**: 기능별 도메인/데이터/프리젠테이션을 갖는 폴더(예: todo).
- **main.dart**: 앱 실행 엔트리.