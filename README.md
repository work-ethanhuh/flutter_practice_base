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
├─ app/
│  ├─ app.dart
│  ├─ bootstrap.dart
│  │
│  ├─ router/
│  │  ├─ app_router.dart
│  │  ├─ app_routes.dart
│  │  ├─ session_gate.dart          // interface (공통)
│  │  └─ session_gate_dummy.dart    // 기본 구현 (공통)
│  │
│  └─ di/
│     └─ app_scope.dart              // 공통 DI 엔트리
│
├─ core/
│  ├─ network/
│  │  ├─ dio_client.dart
│  │  ├─ interceptors/
│  │  │  ├─ auth_interceptor.dart
│  │  │  └─ logging_interceptor.dart
│  │
│  ├─ auth/
│  │  ├─ token_storage.dart
│  │  └─ session_events.dart        // optional (401, logout)
│  │
│  ├─ error/
│  │  ├─ app_exception.dart
│  │  └─ error_mapper.dart
│  │
│  └─ utils/
│     ├─ logger.dart
│     └─ debouncer.dart
│
├─ features/
│  └─ todo/                          // 예시 기능
│     ├─ domain/
│     │  ├─ entity/
│     │  │  └─ todo.dart
│     │  ├─ repository/
│     │  │  └─ todo_repository.dart
│     │  └─ usecase/
│     │     └─ get_todos.dart
│     │
│     ├─ data/
│     │  ├─ dto/
│     │  │  └─ todo_dto.dart
│     │  ├─ datasource/
│     │  │  └─ todo_api.dart
│     │  └─ repository/
│     │     └─ todo_repository_impl.dart
│     │
│     ├─ presentation/
│     │  ├─ state/
│     │  │  ├─ todo_state.dart       // 상태 계약 (공통)
│     │  │  └─ todo_actions.dart     // 액션 계약 (공통)
│     │  │
│     │  ├─ pages/
│     │  │  └─ todo_page.dart        // 컨테이너 (브랜치별)
│     │  │
│     │  └─ widgets/
│     │     └─ todo_view.dart        // 순수 UI (공통)
│     │
│     └─ feature_router.dart         // 선택 (라우트 등록)
│
└─ main.dart
```

간단한 설명
- **app**: 앱 진입점, 라우터, DI 등 앱 레벨 구성.
- **core**: 네트워크, 인증, 에러, 유틸 등 재사용 가능한 공통 모듈.
- **features**: 기능별 도메인/데이터/프리젠테이션을 갖는 폴더(예: todo).
- **main.dart**: 앱 실행 엔트리.