@echo off
chcp 65001 >nul

setlocal enabledelayedexpansion

set LOG_FILE=%~dp0generate_nsh.log
set SCRIPT_PATH=%~dp0scripts\generate_nsh.php
set PHP_EXE=C:\AMPc\PHP\php.exe

if exist "%LOG_FILE%" del "%LOG_FILE%"

echo ======================================== >> "%LOG_FILE%"
echo Inicio: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo ========================================
echo Generador de archivos NSH para AMPc
echo ========================================
echo.

if not exist "%PHP_EXE%" (
    echo [X] ERROR: No se encontro php.exe en %PHP_EXE%
    echo [X] ERROR: No se encontro php.exe en %PHP_EXE% >> "%LOG_FILE%"
    echo.
    echo Por favor verifica la ruta de PHP en el script
    pause
    exit /b 1
)

if not exist "%SCRIPT_PATH%" (
    echo [X] ERROR: No se encontro el script en %SCRIPT_PATH%
    echo [X] ERROR: No se encontro el script en %SCRIPT_PATH% >> "%LOG_FILE%"
    echo.
    echo Asegurate de que el archivo existe en la carpeta scripts
    pause
    exit /b 1
)

echo Ejecutando generador de archivos NSH...
echo Ejecutando generador de archivos NSH... >> "%LOG_FILE%"
echo.
echo. >> "%LOG_FILE%"

"%PHP_EXE%" "%SCRIPT_PATH%" 2>&1 | "%SystemRoot%\System32\findstr.exe" /V "^$" >> "%LOG_FILE%"
set EXIT_CODE=%errorlevel%

timeout /t 1 /nobreak >nul

echo.
echo. >> "%LOG_FILE%"

if %EXIT_CODE% neq 0 (
    echo [X] El script finalizo con errores (Codigo: %EXIT_CODE%)
    echo [X] El script finalizo con errores (Codigo: %EXIT_CODE%) >> "%LOG_FILE%"
    echo.
    echo Ver detalles en: generate_nsh.log
) else (
    echo [OK] Archivos NSH generados exitosamente
    echo [OK] Archivos NSH generados exitosamente >> "%LOG_FILE%"
    echo.
    echo Los archivos generados estan en:
    echo   - components\*\files_install.nsh
    echo   - components\*\uninstall_files.nsh
    echo.
    echo Ver detalles en: generate_nsh.log
)

echo. >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo Fin: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"

echo ========================================
echo Proceso completado
echo ========================================

pause
