# Inner Circle

A peer-support Flutter application for chronic illness communities with AI-powered content moderation.

## Features

- **Community Management**: Create and join communities for different chronic illnesses
- **Forum Discussions**: Topic-based forums within communities
- **Scientific Papers**: Search, view and download research papers (PDF support)
- **AI-Powered Moderation**: Automatic content moderation using Ollama/LLaMA
- **User Authentication**: Firebase Authentication with role-based access (Admin/User)
- **Survey System**: Baseline and follow-up surveys for research purposes
- **Admin Dashboard**: Content review and community management
- **Cross-Platform**: Web, Android, iOS, Windows, macOS support

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Routing**: go_router
- **Backend**: Firebase (Firestore, Auth, Storage)
- **AI/ML**: Ollama (LLaMA 3.2) for content moderation
- **Deployment**: GitHub Pages (Web)

## Prerequisites

- Flutter SDK (3.x or higher)
- Firebase CLI
- Docker Desktop (for Ollama)
- Git

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/jodsals/inner_circle.git
cd inner_circle
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Check installation
firebase --version

# Login to Firebase
firebase login

# Configure FlutterFire
flutterfire configure
```

Select the project `innercircle2025` when prompted.

### 4. Ollama Setup (for AI Moderation)

The app uses Ollama for AI-based content moderation. Follow these steps:

#### Install Docker

- **Windows/Mac**: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Linux**: `sudo apt-get install docker.io`

#### Start Ollama Container

```bash
# Download and start Ollama container
docker run -d -p 11434:11434 --name ollama ollama/ollama

# Verify container is running
docker ps
```

#### Download Model

```bash
# Download llama3.2 model (used for moderation)
docker exec -it ollama ollama pull llama3.2

# Test the model (optional)
docker exec -it ollama ollama run llama3.2 "Hello, how are you?"
```

#### Container Management

```bash
# Stop container
docker stop ollama

# Start container (after stopping)
docker start ollama

# Remove container (if needed)
docker stop ollama
docker rm ollama
```

**Note**: The app expects Ollama at `http://host.docker.internal:11434` (works automatically with Docker Desktop).

### 5. Environment Variables

The app uses environment variables for sensitive configuration. For the Ollama JWT token:

#### Local Development

```bash
flutter run -d chrome --dart-define=OLLAMA_JWT_TOKEN=your_token_here
```

#### Production Build

```bash
flutter build web --release --dart-define=OLLAMA_JWT_TOKEN=your_token_here
```

## Running the App

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run on Chrome (with Ollama token)
flutter run -d chrome --dart-define=OLLAMA_JWT_TOKEN=your_token_here

# Run on other platforms
flutter run -d windows
flutter run -d android
flutter run -d ios
```

## Deployment

### GitHub Pages

The app is configured for automatic deployment to GitHub Pages.

#### Setup

1. **GitHub Secrets**: Add `OLLAMA_JWT_TOKEN` to Repository Secrets
   - Go to: Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `OLLAMA_JWT_TOKEN`
   - Value: Your JWT token

2. **GitHub Pages**: Enable GitHub Actions deployment
   - Go to: Settings → Pages
   - Source: Select "GitHub Actions"

3. **Firebase Console**: Add authorized domain
   - Go to: [Firebase Console](https://console.firebase.google.com/project/innercircle2025/authentication/settings)
   - Authorized domains → Add domain: `jodsals.github.io`

4. **Deploy**: Push to main branch or trigger manually
   ```bash
   git push origin main
   ```
   Or go to Actions tab and run "Deploy to GitHub Pages" workflow manually.

5. **Access**: Visit [https://jodsals.github.io/inner_circle/](https://jodsals.github.io/inner_circle/)

#### Firebase Storage CORS (if using Storage)

```bash
# Configure CORS for Storage
gcloud storage buckets update gs://innercircle2025.firebasestorage.app --cors-file=cors.json
```

### Alternative: Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Build
flutter build web --release --dart-define=OLLAMA_JWT_TOKEN=your_token_here

# Deploy
firebase deploy --only hosting
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
└── src/
    ├── app.dart             # Main app widget
    ├── admin/               # Admin dashboard & management
    ├── auth/                # Authentication & user management
    ├── community/           # Community features
    ├── forum/               # Forum discussions
    ├── post/                # Posts & comments
    ├── search/              # Search functionality
    ├── survey/              # Survey system
    └── core/
        ├── di/              # Dependency injection
        ├── routing/         # Navigation & routing
        └── presentation/    # Shared UI components
```

## Firebase Configuration

### Firestore Collections

- `users` - User profiles and settings
- `communities` - Community information
- `forums` - Forum metadata
- `posts` - Forum posts
- `comments` - Post comments
- `surveys` - Survey responses
- `moderation_queue` - AI-flagged content for review

### Security Rules

Firestore and Storage rules are defined in:
- `firestore.rules`
- `storage.rules`

## Troubleshooting

### Ollama Issues

**Problem**: "Failed to call Ollama API"
- Check if Docker Desktop is running
- Verify container status: `docker ps`
- Test API: `curl http://localhost:11434/api/chat -d '{"model": "llama3.2", "messages": [{"role": "user", "content": "Hi"}], "stream": false}'`

**Problem**: "Model not found"
- Download model: `docker exec -it ollama ollama pull llama3.2`

**Problem**: Port already in use
- Check port: `netstat -ano | findstr 11434` (Windows)
- Use different port: `docker run -d -p 11435:11434 --name ollama ollama/ollama`

### Firebase Issues

**Problem**: "Firebase not initialized"
- Run `flutterfire configure`
- Ensure `firebase_options.dart` exists

**Problem**: Authentication errors on web
- Check if domain is authorized in Firebase Console
- Verify `authDomain` in Firebase config

### Deployment Issues

**Problem**: GitHub Pages shows 404
- Ensure GitHub Pages is enabled (Settings → Pages)
- Check workflow ran successfully (Actions tab)
- Verify `--base-href /inner_circle/` in build command

**Problem**: "OLLAMA_JWT_TOKEN undefined"
- Add secret in GitHub: Settings → Secrets → Actions
- Ensure secret name matches workflow: `OLLAMA_JWT_TOKEN`

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is part of a research initiative for chronic illness support communities.

## Contact

For questions or support, please open an issue on GitHub.

---

**Live Demo**: [https://jodsals.github.io/inner_circle/](https://jodsals.github.io/inner_circle/)
