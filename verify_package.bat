@echo off
echo PDF2PNG Converter Package Verification
echo ====================================
echo.

if exist ".\icon.ico" (
    echo [✓] Icon file found
) else (
    echo [✗] Icon file missing
)

if exist ".\dist\PDF2PNG_Converter.exe" (
    echo [✓] Main executable found
) else (
    echo [✗] Main executable missing
)

if exist ".\PDF2PNG_Converter_Setup.exe" (
    echo [✓] Installer package found
) else (
    echo [✗] Installer package missing
)

if exist ".\poppler-bin\pdftoppm.exe" (
    echo [✓] Poppler binaries found
) else (
    echo [✗] Poppler binaries missing
)

if exist ".\EULA.txt" (
    echo [✓] License agreement found
) else (
    echo [✗] License agreement missing
)

if exist ".\release_notes.md" (
    echo [✓] Release notes found
) else (
    echo [✗] Release notes missing
)

if exist ".\user_guide.md" (
    echo [✓] User guide found
) else (
    echo [✗] User guide missing
)

echo.
echo PDF2PNG Converter v1.0.0
echo © 2025 Minhazul Abedin
echo OkayAbedin
echo All rights reserved.
echo.
echo Press any key to exit...
pause > nul
