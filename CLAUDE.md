# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LokYatra is a cultural tourism app for Nepal with three user roles: **tourist**, **owner** (homestay host), and **admin**. The repo is a monorepo with two independent projects:

- `LokYatra/backend/` — ASP.NET Core 9 REST API
- `LokYatra/frontend/` — Flutter mobile app

## Backend

### Commands (run from `LokYatra/backend/`)

```powershell
dotnet build                                   # compile
dotnet run                                     # start dev server on http://localhost:5257
dotnet ef migrations add <Name>                # create a new EF migration
dotnet ef database update                      # apply pending migrations manually
```

Migrations are also applied automatically at startup via `Database.Migrate()`.

### Tech Stack

- **Framework**: ASP.NET Core 9, EF Core + Npgsql (PostgreSQL)
- **Auth**: JWT bearer tokens (7-day expiry) + refresh tokens; BCrypt password hashing; roles encoded in the `role` claim
- **Images**: Cloudinary (`CloudinaryImageService`)
- **Payments**: Khalti payment gateway (`KhaltiController`)
- **Email**: MailKit/MimeKit over Gmail SMTP (used for password reset)
- **API docs**: OpenAPI + Scalar at `/scalar/v1` or `/docs`
- **Deployment**: Railway — reads `DATABASE_URL` and `PORT` env vars at startup

### Configuration (`appsettings.json`)

Local dev defaults: PostgreSQL on `localhost:5432`, database `lokyatra`, user `postgres`. Keys `AppSettings:Token`, `Cloudinary.*`, `Khalti.SecretKey`, and `Smtp.*` must be populated before auth, image uploads, payments, or email will work.

### Architecture

```
Controllers/   → thin REST controllers, route api/[controller]
Entities/      → EF entity classes (namespace backend.Models)
DTO/           → request/response DTOs
Services/      → IAuthService/AuthService, ICloudImageService/CloudinaryImageService, NotificationService
Database/      → AppDbContext (EF DbContext, all DbSets)
Migrations/    → EF migration history
```

Controllers inject `AppDbContext` directly (no repository layer) except auth which goes through `IAuthService`. Role-based authorization uses `[Authorize(Roles = "admin")]`, `[Authorize(Roles = "owner")]`, etc.

## Frontend

### Commands (run from `LokYatra/frontend/`)

```powershell
flutter pub get                                                        # install dependencies
flutter run                                                            # run on connected device/emulator
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5257        # point at local backend
flutter build apk                                                      # Android release build
```

### Tech Stack

- **State management**: BLoC (`flutter_bloc`)
- **HTTP**: Dio
- **Token storage**: `flutter_secure_storage` (access + refresh tokens)
- **Offline cache**: SQLite via `sqflite` on mobile; `SharedPreferences` on web — both accessed through `SqliteService` singleton
- **UI scaling**: `flutter_screenutil` (design size 375×812)
- **Images**: `cached_network_image` + Cloudinary thumbnails via `cloudinary_thumb.dart`

### Architecture

```
lib/
  main.dart                              # MultiBlocProvider, named routes, AuthBloc navigation listener
  core/services/
    constants.dart                       # apiBaseUrl, endpoint constants (override with --dart-define=API_BASE_URL)
    sqlite_service.dart                  # offline cache singleton (SQLite + SharedPreferences)
    image_proxy.dart
  data/
    models/                              # JSON-serializable models (json_annotation)
    datasources/                         # Remote datasources (raw Dio calls)
    repositories/sqlite_repository.dart  # Cache-then-network strategy for sites
  presentation/
    state_management/Bloc/               # One subfolder per feature: auth, sites, homestays, stories, booking, user, review, notification
    screens/
      authentication/                    # Login, register, forgot/reset password
      TouristScreen/                     # Tourist-facing pages
      OwnerScreen/                       # Owner-facing pages
      admin/                             # Admin panel pages
      shared/
    splash/                              # Splash + onboarding screens
    widgets/Helpers/                     # Shared widgets (review_dialog, favourite_button, etc.)
```

### Navigation & Auth Flow

`main.dart` registers a `BlocListener<AuthBloc>` that intercepts login/logout states and calls `pushNamedAndRemoveUntil` to land on the correct home screen. On cold start the `CheckAuthStatus` event is fired; if the stored JWT is expired or absent it emits `AuthUnauthenticated` which routes to onboarding (first launch) or login.

After login, user profile data (name, email, phone, image) is stored in `SqliteService` under keys `user_name`, `user_email`, `user_phone`, `user_image`.

### Offline Caching

`SqliteService` stores sites and homestays with a 24-hour TTL. The `SqliteRepository` (used by `SitesBloc`) returns cached data immediately and triggers a background network refresh when cache is stale. Permanent keys (`has_seen_onboarding`, `sites_last_sync`, etc.) are never purged by `deleteOldCache`.
