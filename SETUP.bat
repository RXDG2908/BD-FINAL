@echo off
title AUTOFIX - Setup de entorno

echo.
echo ================================================
echo   AUTOFIX - Configuracion de entorno
echo   Base de Datos Avanzado
echo ================================================
echo.

:: ─────────────────────────────────────────────
:: PASO 1: Verificar que VS Code esta instalado
:: ─────────────────────────────────────────────
echo [1/3] Verificando Visual Studio Code...
where code >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo  ERROR: VS Code no encontrado en esta PC.
    echo  Descargalo desde: https://code.visualstudio.com
    echo  Luego vuelve a ejecutar este archivo.
    echo.
    pause
    exit /b 1
)
echo  VS Code encontrado - OK

echo.
echo [2/3] Instalando extensiones necesarias...
echo.

echo  Instalando Oracle SQL Developer...
code --install-extension Oracle.sql-developer --force >nul 2>&1
echo  OK - Oracle SQL Developer

echo  Instalando PL/SQL Language...
code --install-extension xyz.plsql-language --force >nul 2>&1
echo  OK - PL/SQL Language

echo  Instalando SQLTools...
code --install-extension mtxr.sqltools --force >nul 2>&1
echo  OK - SQLTools

echo  Instalando Mermaid (diagrama ER)...
code --install-extension bierner.markdown-mermaid --force >nul 2>&1
echo  OK - Markdown Mermaid

echo.
echo [3/3] Abriendo proyecto en VS Code...
code "%~dp0"

echo.
echo ================================================
echo   LISTO. Datos de conexion Oracle:
echo ================================================
echo   Username  : autofix
echo   Password  : autofix123
echo   Hostname  : localhost
echo   Port      : 1521
echo   Service   : xe
echo ------------------------------------------------
echo   Orden de ejecucion:
echo   01 - 02 - 03 - 04 - 05 - 06 - 07
echo ------------------------------------------------
echo   Diagrama ER: abrir ER_AUTOFIX.md
echo   y presionar Ctrl+Shift+V
echo ================================================
echo.
pause
