@echo off
setlocal

rem Проверяем наличие Node.js и npm.
where node >nul 2>nul
if errorlevel 1 goto NODE_ERROR
where npm >nul 2>nul
if errorlevel 1 goto NODE_ERROR

echo [SETUP] Установка зависимостей
call npm install --no-audit --no-fund
if errorlevel 1 goto NPM_ERROR

rem В архиве исполняемые .js запрещены. Создаём рабочую копию после распаковки.
if not exist .testquest-runtime mkdir .testquest-runtime
copy /Y tests\calculator.test.txt .testquest-runtime\calculator.test.js >nul
if errorlevel 1 goto COPY_ERROR

echo [TEST] Запуск проверок калькулятора и Excel
node --test .testquest-runtime\calculator.test.js
set TEST_EXIT_CODE=%ERRORLEVEL%

if %TEST_EXIT_CODE% EQU 0 (
  echo PASSED
) else (
  echo FAILED
)
exit /b %TEST_EXIT_CODE%

:NODE_ERROR
echo FAILED: требуется Node.js 18+ и npm
exit /b 1

:NPM_ERROR
echo FAILED: не удалось установить npm-зависимости
exit /b 1

:COPY_ERROR
echo FAILED: не удалось подготовить тестовый файл
exit /b 1
