# AssertGuard_app

AssetGuard is a cross‑platform inspection application built with Flutter, designed for environments where connectivity is unreliable. The app enables inspectors to create, edit, and store inspection records fully offline, with secure synchronisation to a Supabase backend when a network connection becomes available.

Key Features
Offline‑first architecture using Drift (SQLite)

Secure cloud sync to Supabase (PostgreSQL + RLS)

Clean Architecture (UI → ViewModel → Repository → Data Sources)

Create, view, and update inspections

Local caching & conflict‑safe sync queue

GDPR‑aligned data handling

Cross‑platform (Android, iOS, Web, Desktop)

Tech Stack
Flutter (Dart)

Drift for local persistence

Supabase for backend, auth, and cloud storage

Riverpod / Provider (depending on your repo) for state management

Repository Pattern for clean separation of concerns

HTTP / Supabase client for API communication

Profile Structure
lib/
 ├── data/
 │    ├── local/ (Drift tables, DAOs)
 │    ├── remote/ (Supabase API services)
 │    └── repositories/ (InspectionRepository)
 ├── domain/
 │    ├── models/ (Inspection, Asset, User)
 │    └── use_cases/
 ├── presentation/
 │    ├── screens/
 │    ├── widgets/
 │    └── viewmodels/
 ├── services/
 │    └── sync_service.dart
 └── main.dart

Offline‑First Sync Flow
User creates/updates an inspection

Data is written to Drift immediately

A sync job is added to the sync queue

When online, the sync service:

Pushes local changes to Supabase

Pulls remote updates

Resolves conflicts using last‑write‑wins (or your chosen strategy)

Security & GDPR
Local data stored in encrypted SQLite (if enabled)

Supabase Row Level Security (RLS) ensures user‑scoped access

No unnecessary personal data stored

Sync uses secure HTTPS endpoints

Data minimisation and purpose limitation principles applied

Getting Started
Prerequisites
Flutter SDK (3.x+)

Dart

Supabase project with:

inspections table

RLS policies

Service role key (server only)

Android SDK

Installation
git clone <https://github.com/ShaneannX/AssertGuard_app>
cd assetguard_app
flutter pub get
flutter run

Testing
The project includes:

Unit tests for repositories

Widget tests for UI components

Manual test plan (functional + offline scenarios)

Debug screen for verifying sync behaviour

Run Tests:
flutter test

Contact
Maintainer: Shaneann  
For academic submission and demonstration purposes.


