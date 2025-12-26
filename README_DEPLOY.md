# GitHub Pages Deployment Guide

## Automatische Deployment (Empfohlen)

Die App wird automatisch deployed, wenn Sie zu `main` pushen:

1. **Aktivieren Sie GitHub Actions:**
   - Gehen Sie zu: https://github.com/jodsals/inner_circle/settings/pages
   - Unter "Build and deployment" > "Source" wählen Sie: **"GitHub Actions"**

2. **Pushen Sie Ihre Änderungen:**
   ```bash
   git add .
   git commit -m "Setup GitHub Pages deployment"
   git push
   ```

3. **Warten Sie auf das Deployment:**
   - Gehen Sie zu: https://github.com/jodsals/inner_circle/actions
   - Der Workflow "Deploy to GitHub Pages" wird automatisch ausgeführt
   - Nach ca. 2-5 Minuten ist Ihre App verfügbar

4. **Ihre App ist live unter:**
   - **https://jodsals.github.io/inner_circle/**

## Manuelles Deployment

Falls Sie lieber manuell deployen möchten:

### Windows:
```bash
# Führen Sie das Deployment-Skript aus
deploy.bat
```

### Oder manuell:

1. **Build erstellen:**
   ```bash
   flutter build web --release --base-href /inner_circle/ --web-renderer html
   ```

2. **Build zu GitHub Pages deployen:**
   ```bash
   # Installieren Sie gh-pages (einmalig)
   npm install -g gh-pages

   # Deploy
   gh-pages -d build/web
   ```

3. **GitHub Pages konfigurieren:**
   - Gehen Sie zu: https://github.com/jodsals/inner_circle/settings/pages
   - Source: `gh-pages` branch, `/ (root)` folder
   - Speichern

4. **Fertig!** Ihre App ist unter https://jodsals.github.io/inner_circle/ verfügbar

## Wichtige Hinweise

### Firebase Konfiguration
Stellen Sie sicher, dass Ihre Firebase-App für die GitHub Pages Domain konfiguriert ist:
- Gehen Sie zur Firebase Console
- Project Settings > Authorized domains
- Fügen Sie hinzu: `jodsals.github.io`

### Web Renderer
- **HTML Renderer** (verwendet in deploy.bat): Schnelleres Laden, kleinere Dateigröße
- **CanvasKit Renderer**: Bessere Performance, aber größere Dateien

Um CanvasKit zu verwenden:
```bash
flutter build web --release --base-href /inner_circle/ --web-renderer canvaskit
```

### Custom Domain (Optional)
Falls Sie eine eigene Domain verwenden möchten:
1. Erstellen Sie eine `CNAME` Datei in `web/` mit Ihrer Domain
2. Fügen Sie Ihre Domain in `deploy.yml` unter `cname:` hinzu
3. Konfigurieren Sie DNS-Records bei Ihrem Domain-Provider

## Troubleshooting

### 404 Fehler nach Reload
Fügen Sie eine `404.html` im `web/` Ordner hinzu, die identisch zu `index.html` ist:
```bash
cp web/index.html web/404.html
```

### Build Fehler
```bash
# Cache leeren
flutter clean
flutter pub get
flutter build web --release --base-href /inner_circle/
```

### Firebase Auth funktioniert nicht
Überprüfen Sie:
1. Authorized domains in Firebase Console
2. API Keys in Firebase Config
3. Browser Console für Fehler
