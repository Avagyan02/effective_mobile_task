PROCESS_NAME="test"
LOG_FILE="/var/log/monitoring.log"
MONITORING_URL="https://test.com/monitoring/test/api"
PREVIOUS_STATUS_FILE="/tmp/monitor_test_status"

touch "$LOG_FILE"

touch "$PREVIOUS_STATUS_FILE"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Скрипт запущен" >> "$LOG_FILE"

is_running=$(pgrep -x "$PROCESS_NAME")

if [[ -n "$is_running" ]]; then
    current_status="running"

    echo "$(date '+%Y-%m-%d %H:%M:%S') - Процесс $PROCESS_NAME найден" >> "$LOG_FILE"

    if [[ "$(cat "$PREVIOUS_STATUS_FILE")" != "$current_status" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Процесс $PROCESS_NAME был перезапущен" >> "$LOG_FILE"
    fi

    if curl --silent --head --fail "$MONITORING_URL"; then
        curl --silent --request POST "$MONITORING_URL" > /dev/null
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Сервер мониторинга доступен" >> "$LOG_FILE"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Сервер мониторинга недоступен" >> "$LOG_FILE"
    fi
else
    current_status="not_running"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Процесс $PROCESS_NAME не запущен" >> "$LOG_FILE"
fi

echo "$current_status" > "$PREVIOUS_STATUS_FILE"
