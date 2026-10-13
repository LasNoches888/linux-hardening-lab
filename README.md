# linux-hardening-lab

Базовое усиление безопасности Linux-сервера (CIS-подобный чеклист) + скрипт аудита.

## Содержание
- `hardening_checklist.md` — чеклист по SSH, firewall, обновлениям, аудиту
- `scripts/audit.sh` — быстрая проверка текущего состояния
- `configs/sshd_hardened.conf` — усиленный конфиг SSH

## Дополнительно
- `configs/sysctl_hardening.conf`, `configs/nftables_baseline.conf`, `configs/fail2ban_jail.local`, `configs/auditd_rules.rules` — готовые конфигурации.
- `scripts/check_sysctl.sh` — сравнивает параметры ядра с эталоном (только чтение).
- `docs/lynis_walkthrough.md` — аудит с помощью Lynis; `docs/rollback.md` — безопасное применение и откат.
