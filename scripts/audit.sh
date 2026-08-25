#!/usr/bin/env bash
# Быстрый аудит настроек безопасности (read-only)
echo "=== SSH root login ==="
grep -i "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null || echo "не задано (default permit)"
echo "=== SSH password auth ==="
grep -i "^PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null || echo "не задано"
echo "=== Открытые порты ==="
ss -tuln 2>/dev/null || netstat -tuln 2>/dev/null
echo "=== Пользователи с пустым паролем ==="
awk -F: '($2==""){print $1}' /etc/shadow 2>/dev/null || echo "нет доступа к /etc/shadow"
