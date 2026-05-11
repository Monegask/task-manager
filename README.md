# task_manager

Персональный кросс-платформенный таск-менеджер с offline-first хранилищем
и облачной синхронизацией. Android + Windows в MVP, iOS — позже.

## Стек

- **Flutter / Dart** — единая кодовая база (Android, Windows, iOS-ready)
- **Supabase** — Postgres + Auth + Realtime (free tier)
- **drift (SQLite)** — локальное offline-first хранилище
- **Riverpod** — state management
- **go_router** — навигация
- **rrule** — повторяющиеся задачи (RFC 5545)
- **table_calendar** — UI календаря
- **flutter_local_notifications** — локальные уведомления без push-сервера

## Пререквизиты

- Flutter SDK `^3.27.0` (Dart `^3.6.0`) — [установка](https://docs.flutter.dev/get-started/install)
- Android SDK + Android Studio command-line tools (для Android-сборки)
- Visual Studio 2022 с компонентом «Desktop development with C++» (для Windows-сборки)
- (Опционально, на будущее) Xcode + macOS — для iOS

Проверь, что всё доступно:

```bash
flutter doctor -v
```

## Настройка Supabase

1. Зарегистрируйся на <https://supabase.com> (бесплатный tier).
2. **New project** → выбери регион поближе, придумай DB password (его нигде не используем напрямую, но Supabase сохранит).
3. В созданном проекте: **Project Settings → API**.
4. Скопируй два значения:
   - **Project URL** — попадёт в `SUPABASE_URL`
   - **Project API keys → anon / public** — попадёт в `SUPABASE_ANON_KEY`
5. В корне репо: `cp .env.example .env` и подставь значения.

> `anon` ключ публичный — он только подтверждает «я аноним из вашего проекта».
> Безопасность данных обеспечивается Row-Level Security (RLS), которая
> включается миграцией на Этапе 2.

SQL-миграции схемы будут лежать в `supabase/migrations/` начиная с Этапа 2.

## Локальный запуск

```bash
# один раз — установить зависимости
flutter pub get

# на каждый чувствительный к codegen чейндж (drift / riverpod_generator)
dart run build_runner build --delete-conflicting-outputs

# запуск
flutter run -d windows           # Windows desktop
flutter run -d <android-device>  # подключенный по USB Android
flutter devices                   # посмотреть список доступных устройств
```

## Структура проекта

```
lib/
├── main.dart              # bootstrap: dotenv → Supabase init → ProviderScope
├── app.dart               # MaterialApp.router + темы
├── core/
│   └── config/env.dart    # типизированный доступ к .env
├── data/                  # реализация: drift, supabase, репозитории  (Этапы 1-2)
├── domain/                # доменные модели и сервисы                  (Этапы 1-5)
├── features/              # экраны по фичам: auth, tasks, calendar     (Этапы 3-6)
├── routing/
│   └── app_router.dart    # go_router
└── shared/                # переиспользуемые виджеты
test/
└── widget_test.dart       # smoke-test bootstrap'а
supabase/
└── migrations/            # SQL-миграции схемы                          (Этап 2)
```

Принцип: `domain/` не знает про drift и Supabase. `data/` маппит туда-обратно.
`features/` зависит только от `domain/` и провайдеров.

## Поэтапный план

| Этап | Описание | Статус |
| ---- | -------- | ------ |
| 0 | Инициализация: каркас, зависимости, конфиг | ✅ |
| 1 | Drift-схема, DAO, тесты CRUD | ⏳ |
| 2 | Supabase + sync (pull/push/realtime, LWW) | ⏳ |
| 3 | UI задач: список с фильтрами + форма | ⏳ |
| 4 | Календарь: месяц/неделя/день + DnD на Windows | ⏳ |
| 5 | Повторяющиеся задачи: RRULE-билдер + логика | ⏳ |
| 6 | Auth + полировка (тёмная тема, error states) | ⏳ |
| 7 | Сборка: Android APK, Windows portable | ⏳ |
| 8 | iOS-таргет (отложено, до появления iPhone) | 🔒 |

## Тесты

```bash
flutter test                     # все тесты
flutter test --coverage          # с покрытием → coverage/lcov.info
flutter analyze                  # статический анализ
```

Цель: ≥70% покрытия критичной логики (sync, recurrence).

## Лицензия

MIT — см. [LICENSE](LICENSE).
