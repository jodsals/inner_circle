@echo off
echo ====================================
echo Deploying to GitHub Pages
echo ====================================
echo.

REM Build the Flutter web app
echo [1/4] Building Flutter web app...
flutter build web --release --base-href /inner_circle/ --dart-define=OLLAMA_JWT_TOKEN=%OLLAMA_JWT_TOKEN%

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    exit /b %ERRORLEVEL%
)

echo [2/4] Preparing gh-pages branch...

REM Save current branch
for /f "delims=" %%i in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%i

REM Check if gh-pages branch exists
git show-ref --verify --quiet refs/heads/gh-pages
if %ERRORLEVEL% EQU 0 (
    echo gh-pages branch exists, switching to it...
    git checkout gh-pages
) else (
    echo Creating gh-pages branch...
    git checkout --orphan gh-pages
    git rm -rf .
)

echo [3/4] Copying build files...

REM Remove old files (keep .git)
for /d %%i in (*) do (
    if not "%%i"==".git" (
        rd /s /q "%%i"
    )
)
del /q * 2>nul

REM Copy new build files
xcopy /E /I /Y build\web\* .

REM Create .nojekyll file (important for GitHub Pages)
echo. > .nojekyll

echo [4/4] Committing and pushing...

REM Commit and push
git add .
git commit -m "Deploy to GitHub Pages - %date% %time%"
git push origin gh-pages --force

REM Return to original branch
git checkout %CURRENT_BRANCH%

echo.
echo ====================================
echo Deployment successful!
echo ====================================
echo.
echo Your site will be available at:
echo https://jodsals.github.io/inner_circle/
echo.
echo Note: It may take a few minutes for changes to appear.
echo.
pause
