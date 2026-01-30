# GMN Flutter App

A Flutter mobile application for field service management, converted from the original React web app.

## Features

- **Authentication**: JWT-based login/register with secure token storage
- **Dashboard**: Overview stats, charts, recent activity, and alerts
- **Work Orders**: Full CRUD with status management, filters, and technician assignment
- **Technicians**: Manage technicians with blacklist functionality and performance tracking
- **Proposals**: Service proposals with cost calculator and parts management
- **Costs**: Payment request workflow with approval process
- **Files**: Upload, preview, and manage images and documents
- **Calendar**: Month view calendar with events and work order ETAs
- **Commission Calculator**: Tiered commission calculation with qualification rules
- **Income Statement**: Financial reports with charts and KPIs

## Getting Started

### Prerequisites

- Flutter SDK 3.10.3 or higher
- Dart SDK 3.10.3 or higher
- Android Studio / Xcode for mobile development

### Installation

1. Navigate to the Flutter app directory:
   ```bash
   cd gmn_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Backend Setup

This app connects to the existing Node.js/Express backend. Make sure the backend server is running:

```bash
cd ../server
npm install
npm run dev
```

The backend runs on `http://localhost:3001`.

### API Configuration

Update the base URL in `lib/core/constants/api_constants.dart`:

```dart
// For Android emulator
static const String baseUrl = 'http://10.0.2.2:3001/api';

// For iOS simulator
static const String baseUrl = 'http://localhost:3001/api';

// For production
static const String baseUrl = 'https://your-domain.com/api';
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # App configuration
├── core/
│   ├── api/                     # API client and exceptions
│   ├── constants/               # App and API constants
│   ├── theme/                   # Theme and colors
│   ├── utils/                   # Formatters and validators
│   └── widgets/                 # Shared widgets
├── features/
│   ├── auth/                    # Authentication
│   ├── dashboard/               # Dashboard
│   ├── work_orders/             # Work Orders
│   ├── technicians/             # Technicians
│   ├── proposals/               # Proposals
│   ├── costs/                   # Costs
│   ├── files/                   # Files
│   ├── calendar/                # Calendar
│   ├── commission/              # Commission Calculator
│   └── income_statement/        # Income Statement
└── routing/
    ├── app_router.dart          # Route configuration
    └── app_shell.dart           # Bottom navigation shell
```

## Key Dependencies

- **flutter_riverpod**: State management
- **go_router**: Navigation
- **dio**: HTTP client
- **flutter_secure_storage**: Secure token storage
- **fl_chart**: Charts
- **table_calendar**: Calendar widget
- **image_picker**: Image capture
- **file_picker**: File selection
- **cached_network_image**: Image caching
- **google_fonts**: Typography

## Demo Credentials

- Email: `demo@gmn.com`
- Password: `demo123`

## Building for Production

### Android

```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## License

Private - All rights reserved
