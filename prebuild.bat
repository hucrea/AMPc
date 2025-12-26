@echo off
chcp 65001 >nul
set LOG_FILE=%~dp0prebuild.log
set PHP_EXE=C:\AMPc\PHP\php.exe

set SCRIPT1_PATH=%~dp0scripts\update_components.php
set SCRIPT2_PATH=%~dp0scripts\generate_nsh.php
set SCRIPT3_PATH=%~dp0scripts\create_versions_file.php

if exist "%LOG_FILE%" del "%LOG_FILE%"

title Pre-build AMPc
color 0A

if not exist "%PHP_EXE%" (
    echo [X] ERROR: No se encontro php.exe en la carpeta %PHP_EXE%
    echo [X] ERROR: No se encontro php.exe en la carpeta %PHP_EXE% >> "%LOG_FILE%"
    pause
    exit /b 1
)

if not exist "%SCRIPT1_PATH%" (
    echo [X] ERROR: No se encontro %SCRIPT1_PATH%
    echo [X] ERROR: No se encontro %SCRIPT1_PATH% >> "%LOG_FILE%"
    pause
    exit /b 1
)

if not exist "%SCRIPT2_PATH%" (
    echo [X] ERROR: No se encontro %SCRIPT2_PATH%
    echo [X] ERROR: No se encontro %SCRIPT2_PATH% >> "%LOG_FILE%"
    pause
    exit /b 1
)

if not exist "%SCRIPT3_PATH%" (
    echo [X] ERROR: No se encontro %SCRIPT3_PATH%
    echo [X] ERROR: No se encontro %SCRIPT3_PATH% >> "%LOG_FILE%"
    pause
    exit /b 1
)

:menu
cls
echo ========================================
echo Pre-build AMPc v1.0
echo ========================================
echo.
echo [1] Actualizar componentes
echo     %SCRIPT1_PATH%
echo.
echo [2] Generar NSH para componentes
echo     %SCRIPT2_PATH%
echo.
echo [3] Generar Versions.nsh
echo     %SCRIPT3_PATH%
echo.
echo [0] Salir
echo.
echo ========================================
echo.

set /p opcion="Selecciona una opción: "

if "%opcion%"=="1" goto script1
if "%opcion%"=="2" goto script2
if "%opcion%"=="3" goto script3
if "%opcion%"=="0" goto salir

echo.
echo Opción no válida. Presiona cualquier tecla para continuar...
pause >nul
goto menu

:script1
cls
echo. >> "%LOG_FILE%"
echo Ejecutando %SCRIPT1_PATH%...
echo Ejecutando %SCRIPT1_PATH%... >> "%LOG_FILE%"
echo.
echo. >> "%LOG_FILE%"

"%PHP_EXE%" "%SCRIPT1_PATH%" 2>&1 | "%SystemRoot%\System32\findstr.exe" /V "^$" >> "%LOG_FILE%"

echo Script finalizado. Presiona cualquier tecla para volver al menú...
pause >nul
goto menu

:script2
cls
echo. >> "%LOG_FILE%"
echo Ejecutando %SCRIPT2_PATH%...
echo Ejecutando %SCRIPT2_PATH%... >> "%LOG_FILE%"
echo.
echo. >> "%LOG_FILE%"

"%PHP_EXE%" "%SCRIPT2_PATH%" 2>&1 | "%SystemRoot%\System32\findstr.exe" /V "^$" >> "%LOG_FILE%"

echo Script finalizado. Presiona cualquier tecla para volver al menú...
pause >nul
goto menu

:script3
cls
echo. >> "%LOG_FILE%"
echo Ejecutando %SCRIPT3_PATH%...
echo Ejecutando %SCRIPT3_PATH%... >> "%LOG_FILE%"
echo.
echo. >> "%LOG_FILE%"

"%PHP_EXE%" "%SCRIPT3_PATH%" 2>&1 | "%SystemRoot%\System32\findstr.exe" /V "^$" >> "%LOG_FILE%"

echo Script finalizado. Presiona cualquier tecla para volver al menú...
pause >nul
goto menu

:salir
cls
echo Cerrando...
echo.
timeout /t 1 >nul
exit