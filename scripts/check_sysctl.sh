#!/usr/bin/env bash
# Сравнивает текущие параметры ядра с configs/sysctl_hardening.conf (только чтение, ничего не меняет).
#
# Использование: scripts/check_sysctl.sh [файл_с_параметрами]
# Коды возврата: 0 — всё совпадает, 1 — есть расхождения, 2 — нет команды sysctl или файла.
set -uo pipefail

CONF="${1:-$(dirname "${BASH_SOURCE[0]}")/../configs/sysctl_hardening.conf}"

if ! command -v sysctl >/dev/null 2>&1; then
    echo "Команда sysctl не найдена (скрипт предназначен для Linux)" >&2
    exit 2
fi
if [[ ! -r "$CONF" ]]; then
    echo "Не удаётся прочитать файл: $CONF" >&2
    exit 2
fi

ok=0 diff=0 missing=0

while IFS= read -r line; do
    # пропускаем пустые строки и комментарии
    [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue
    key="${line%%=*}"
    want="${line#*=}"
    key="$(echo "$key" | xargs)"
    want="$(echo "$want" | xargs)"

    if have="$(sysctl -n "$key" 2>/dev/null)"; then
        have="$(echo "$have" | xargs)"
        if [[ "$have" == "$want" ]]; then
            printf 'OK       %-45s = %s\n' "$key" "$have"
            ok=$((ok + 1))
        else
            printf 'DIFF     %-45s сейчас %s, ожидается %s\n' "$key" "$have" "$want"
            diff=$((diff + 1))
        fi
    else
        printf 'MISSING  %-45s (параметра нет в этом ядре)\n' "$key"
        missing=$((missing + 1))
    fi
done <"$CONF"

echo
echo "Итого: совпало $ok, отличается $diff, не найдено $missing"
(( diff == 0 ))
