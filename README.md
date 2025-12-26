# Inner Circle

Eine Peer-Support Flutter-Anwendung für chronisch Kranke mit KI-gestützter Content-Moderation.

## Features

- **Community-Verwaltung**: Erstelle und trete Communities für verschiedene chronische Krankheiten bei
- **Forum-Diskussionen**: Themenbasierte Foren innerhalb von Communities
- **Wissenschaftliche Artikel**: Suche, betrachte und lade Forschungsarbeiten herunter (PDF-Support)
- **KI-gestützte Moderation**: Automatische Content-Moderation über externe Ollama-API
- **Benutzer-Authentifizierung**: Firebase Authentication mit rollenbasiertem Zugriff (Admin/User)
- **Umfrage-System**: Baseline- und Follow-up-Umfragen für Forschungszwecke
- **Admin-Dashboard**: Content-Review und Community-Verwaltung
- **Plattformübergreifend**: Web, Android, iOS, Windows, macOS Support

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Routing**: go_router
- **Backend**: Firebase (Firestore, Auth, Storage)
- **AI/ML**: Externe Ollama-API (LLaMA 3.2) für Content-Moderation
- **Deployment**: GitHub Pages (Web)

## Voraussetzungen

- Flutter SDK (3.x oder höher)
- Firebase CLI
- Git

## Installation

### 1. Repository klonen

```bash
git clone https://github.com/jodsals/inner_circle.git
cd inner_circle
```

### 2. Dependencies installieren

```bash
flutter pub get
```

### 3. Firebase Setup

```bash
# Firebase CLI installieren
npm install -g firebase-tools

# Installation prüfen
firebase --version

# Bei Firebase einloggen
firebase login

# FlutterFire konfigurieren
flutterfire configure
```

Wähle das Projekt `innercircle2025` aus, wenn du dazu aufgefordert wirst.

### 4. Ollama-API Konfiguration

Die App nutzt eine **externe Ollama-API** für die KI-basierte Content-Moderation.

**Wichtig**:
- Die App verwendet einen JWT-Token für die Authentifizierung bei der Ollama-API
- **Lokales Ollama wird NICHT unterstützt** - nur externe API mit JWT-Token
- Der Token muss als Environment Variable konfiguriert werden (siehe nächster Abschnitt)

### 5. Environment Variables

Die App verwendet Environment Variables für sensible Konfiguration:

#### Lokale Entwicklung

```bash
flutter run -d chrome --dart-define=OLLAMA_JWT_TOKEN=dein_token_hier
```

#### Production Build

```bash
flutter build web --release --dart-define=OLLAMA_JWT_TOKEN=dein_token_hier
```

**Wichtig**: Der JWT-Token sollte niemals im Quellcode stehen. Verwende immer `--dart-define`.

## App starten

```bash
# Clean build
flutter clean

# Dependencies holen
flutter pub get

# Auf Chrome starten (mit Ollama-Token)
flutter run -d chrome --dart-define=OLLAMA_JWT_TOKEN=dein_token_hier

# Auf anderen Plattformen
flutter run -d windows
flutter run -d android
flutter run -d ios
```

## Deployment

### GitHub Pages (Manuell)

Die App kann manuell zu GitHub Pages deployed werden.

#### Schritt-für-Schritt

**1. Environment Variable setzen** (Windows CMD):

```cmd
set OLLAMA_JWT_TOKEN=dein_token_hier
```

**2. Deploy-Script ausführen**:

```cmd
deploy-to-gh-pages.bat
```

Das Script:
- Baut die Flutter Web App
- Erstellt/aktualisiert den `gh-pages` Branch
- Pusht die Build-Dateien zu GitHub

**3. GitHub Pages aktivieren**:
- Gehe zu: https://github.com/jodsals/inner_circle/settings/pages
- Source: "Deploy from a branch"
- Branch: "gh-pages" → "/ (root)"
- Save

**4. Fertig!**

Die App ist dann verfügbar unter:
**https://jodsals.github.io/inner_circle/**

### Alternative: Firebase Hosting

```bash
# Firebase CLI installieren
npm install -g firebase-tools

# Login
firebase login

# Build
flutter build web --release --dart-define=OLLAMA_JWT_TOKEN=dein_token_hier

# Hosting initialisieren (nur beim ersten Mal)
firebase init hosting
# - Public directory: build/web
# - Single-page app: Yes
# - GitHub deployment: No

# Deploy
firebase deploy --only hosting
```

App dann verfügbar unter:
- `https://innercircle2025.web.app`
- `https://innercircle2025.firebaseapp.com`

## Projekt-Struktur

```
lib/
├── main.dart                 # App-Einstiegspunkt
├── firebase_options.dart     # Firebase-Konfiguration
└── src/
    ├── app.dart             # Haupt-App-Widget
    ├── admin/               # Admin-Dashboard & Verwaltung
    ├── auth/                # Authentifizierung & Benutzerverwaltung
    ├── community/           # Community-Features
    ├── forum/               # Forum-Diskussionen
    ├── post/                # Posts & Kommentare
    ├── search/              # Suchfunktion
    ├── survey/              # Umfrage-System
    └── core/
        ├── di/              # Dependency Injection
        ├── routing/         # Navigation & Routing
        └── presentation/    # Geteilte UI-Komponenten
```

## Firebase-Konfiguration

### Firestore Collections

- `users` - Benutzerprofile und Einstellungen
- `communities` - Community-Informationen
- `forums` - Forum-Metadaten
- `posts` - Forum-Posts
- `comments` - Post-Kommentare
- `surveys` - Umfrage-Antworten
- `moderation_queue` - KI-markierte Inhalte zur Überprüfung

### Security Rules

Firestore- und Storage-Regeln sind definiert in:
- `firestore.rules`
- `storage.rules`

### Authorized Domains

Für Web-Deployment müssen Domains in Firebase autorisiert werden:

1. Gehe zu: [Firebase Console → Authentication → Settings](https://console.firebase.google.com/project/innercircle2025/authentication/settings)
2. Unter "Authorized domains" hinzufügen:
   - Für GitHub Pages: `jodsals.github.io`
   - Für Firebase Hosting: `innercircle2025.web.app` (bereits vorhanden)

### Storage CORS (falls verwendet)

Falls Firebase Storage genutzt wird:

```bash
# CORS konfigurieren
gcloud storage buckets update gs://innercircle2025.firebasestorage.app --cors-file=cors.json
```

## Troubleshooting

### Ollama-API-Probleme

**Problem**: "Failed to call Ollama API"
- JWT-Token prüfen (gültig und nicht abgelaufen?)
- API-Endpoint erreichbar?
- Netzwerkverbindung prüfen
- Token als Environment Variable korrekt gesetzt?

**Problem**: "OLLAMA_JWT_TOKEN undefined"
- Environment Variable vor Build setzen: `set OLLAMA_JWT_TOKEN=dein_token`
- Bei Deploy-Script: Token muss gesetzt sein vor Ausführung

### Firebase-Probleme

**Problem**: "Firebase not initialized"
- Lösung: `flutterfire configure` ausführen
- Sicherstellen, dass `firebase_options.dart` existiert

**Problem**: Authentifizierungsfehler im Web
- Prüfen, ob Domain in Firebase Console autorisiert ist
- `authDomain` in Firebase-Config überprüfen

### Deployment-Probleme

**Problem**: GitHub Pages zeigt 404
- GitHub Pages in Settings aktivieren
- Branch auf "gh-pages" setzen
- `--base-href /inner_circle/` im Build-Befehl prüfen

**Problem**: Deploy-Script schlägt fehl
- Git-Status prüfen: Keine uncommitted changes
- Schreibrechte für Repository prüfen
- Token-Environment-Variable gesetzt?

## Mitarbeit

1. Repository forken
2. Feature-Branch erstellen (`git checkout -b feature/neues-feature`)
3. Änderungen committen (`git commit -m 'Neues Feature hinzugefügt'`)
4. Branch pushen (`git push origin feature/neues-feature`)
5. Pull Request öffnen

## Lizenz

Dieses Projekt ist Teil einer Forschungsinitiative für chronisch Kranke Support-Communities.

## Kontakt

Bei Fragen oder Support bitte ein Issue auf GitHub öffnen.

---

**Live Demo**: [https://jodsals.github.io/inner_circle/](https://jodsals.github.io/inner_circle/)
