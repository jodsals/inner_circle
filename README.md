# inner_circle

// Dieses Repo enthält ein minimales Skeleton fuer das InnerCircle-Projekt.
// - Führe `flutter pub get` aus
// - Ergänze Firebase / Supabase Init in main.dart
// - Die wichtigsten Module und Dateien liegen unter lib/src

Initializiere/ Setup Firebase -> im terminal

npm install -g firebase-tools
firebase --version -> prüfe, ob firebase installiert wurde
firebase login -> mit Google Account einloggen
flutterfire configure -> projekt wählen

Optional:
firebase projects:list -> Zeigt nach dem Login die Projekte auf dem Account

Am ende der Arbeit:
firebase logout -> logout

zum Starten:
flutter clean
flutter pub get
flutter run

## Ollama Setup (für KI-Moderation)

Die App nutzt Ollama für die KI-basierte Content-Moderation. Ollama muss lokal mit Docker laufen.

### 1. Docker installieren

Falls noch nicht installiert, lade Docker Desktop herunter:
- **Windows/Mac**: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Linux**: `sudo apt-get install docker.io`

### 2. Ollama Docker Container starten

```bash
# Ollama Container herunterladen und starten
docker run -d -p 11434:11434 --name ollama ollama/ollama

# Prüfen, ob Container läuft
docker ps
```

### 3. Modell herunterladen

```bash
# Modell "llama3.2" herunterladen (wird für die Moderation verwendet)
docker exec -it ollama ollama pull llama3.2

# Optional: Testen, ob das Modell funktioniert
docker exec -it ollama ollama run llama3.2 "Hello, how are you?"
```

### 4. Ollama API testen

```bash
# Test-Anfrage an die Ollama API
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2",
  "messages": [{"role": "user", "content": "Hi"}],
  "stream": false
}'
```

### 5. Container verwalten

```bash
# Container stoppen
docker stop ollama

# Container starten (nach dem Stoppen)
docker start ollama

# Container entfernen (falls nötig)
docker stop ollama
docker rm ollama
```

### Konfiguration

Die Ollama-Konfiguration in der App:
- **URL**: `http://host.docker.internal:11434` (für Docker Desktop)
- **Modell**: `llama3.2`
- **Endpoint**: `/api/chat`

**Wichtig**: Die App erwartet, dass Ollama unter `http://host.docker.internal:11434` erreichbar ist. Dieser Hostname funktioniert automatisch mit Docker Desktop.

### Troubleshooting

**Problem**: "Failed to call Ollama API"
- Prüfe, ob Docker Desktop läuft
- Prüfe, ob Ollama Container läuft: `docker ps`
- Teste die API mit curl (siehe oben)

**Problem**: "Model not found"
- Lade das Modell herunter: `docker exec -it ollama ollama pull llama3.2`

**Problem**: Container startet nicht
- Prüfe, ob Port 11434 bereits belegt ist: `netstat -ano | findstr 11434` (Windows)
- Verwende einen anderen Port: `docker run -d -p 11435:11434 --name ollama ollama/ollama`
- Passe die URL in der App an (`ai_moderation_service.dart`)
