@echo off
echo Building Flutter Web for GitHub Pages...

REM Build the web app with correct base-href
flutter build web --release --base-href /inner_circle/ --web-renderer html

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    exit /b %ERRORLEVEL%
)

echo.
echo Build successful!
echo.
echo Next steps:
echo 1. Commit and push changes: git add . && git commit -m "Update" && git push
echo 2. Go to: https://github.com/jodsals/inner_circle/settings/pages
echo 3. Set source to "gh-pages" branch
echo 4. Your site will be available at: https://jodsals.github.io/inner_circle/
echo.
echo Or use the GitHub Actions workflow to auto-deploy on push!
pause
