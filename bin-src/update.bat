@echo off
chcp 65001 >nul

set LOG_FILE=%~dp0update.log
set SCRIPT_PATH=%~dp0update.php
set PHP_EXE=C:\AMPc\PHP\php.exe

if exist "%LOG_FILE%" del "%LOG_FILE%"

echo ======================================== >> "%LOG_FILE%"
echo Inicio: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo ========================================
echo Actualizando desde archivos ZIP
echo ========================================

if not exist "%PHP_EXE%" (
    echo [X] ERROR: No se encontro php.exe en la carpeta %PHP_EXE%
    echo [X] ERROR: No se encontro php.exe en la carpeta %PHP_EXE% >> "%LOG_FILE%"
    pause
    exit /b 1
)

if not exist "%SCRIPT_PATH%" (
    echo [X] ERROR: No se encontro el archivo update.php
    echo [X] ERROR: No se encontro el archivo update.php >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo. >> "%LOG_FILE%"
echo Ejecutando script...
echo Ejecutando script... >> "%LOG_FILE%"
echo.
echo. >> "%LOG_FILE%"

"%PHP_EXE%" "%SCRIPT_PATH%" 2>&1 | "%SystemRoot%\System32\findstr.exe" /V "^$" >> "%LOG_FILE%"

set EXIT_CODE=%errorlevel%

timeout /t 1 /nobreak >nul

if %EXIT_CODE% neq 0 (
    echo [X] El script finalizo con errores (Codigo: %EXIT_CODE%)
    echo [X] El script finalizo con errores (Codigo: %EXIT_CODE%) >> "%LOG_FILE%"
)

echo.
echo. >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo Fin: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"

echo ========================================
echo Proceso completado
echo Ver detalles en: update.log
echo ========================================
pause