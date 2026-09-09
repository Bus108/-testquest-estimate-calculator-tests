#!/usr/bin/env bash

# Останавливаем скрипт при ошибке установки, но отдельно обрабатываем код тестов.
set -u

echo "[SETUP] Проверка Node.js и npm"

# В песочнице Node.js может называться nodejs, а npm не всегда видит его через env.
NODE_BIN="$(type -P node || type -P nodejs || true)"
NPM_BIN="$(type -P npm || true)"

if [ -z "$NODE_BIN" ] || [ -z "$NPM_BIN" ]; then
  echo "FAILED: требуется Node.js 18+ и npm"
  exit 1
fi

# Добавляем для npm обычное имя node в локальный PATH.
RUNTIME_DIR=".testquest-runtime"
mkdir -p "$RUNTIME_DIR"
ln -sf "$NODE_BIN" "$RUNTIME_DIR/node"
export PATH="$PWD/$RUNTIME_DIR:$PATH"

# На обычной установке npm — это ссылка на npm-cli.js.
NPM_CLI="$(readlink -f "$NPM_BIN")"

echo "[SETUP] Установка зависимостей"
if ! "$NODE_BIN" "$NPM_CLI" install --no-audit --no-fund; then
  echo "FAILED: не удалось установить npm-зависимости"
  exit 1
fi

# В архиве исполняемые .js запрещены. Создаём рабочую копию после распаковки.
cp tests/calculator.test.txt "$RUNTIME_DIR/calculator.test.js"

echo "[TEST] Запуск проверок калькулятора и Excel"
"$NODE_BIN" --test "$RUNTIME_DIR/calculator.test.js"
TEST_EXIT_CODE=$?

if [ "$TEST_EXIT_CODE" -eq 0 ]; then
  echo "PASSED"
else
  echo "FAILED"
fi

exit "$TEST_EXIT_CODE"
