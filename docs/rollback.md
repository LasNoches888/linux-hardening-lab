# Безопасное применение и откат

Усиление защиты легко «запереть» самого себя. Следуйте этим правилам при работе на удалённом сервере.

## Перед изменениями

1. **Откройте вторую SSH-сессию** и не закрывайте её, пока не проверите вход новой.
2. Сделайте копию конфигурации:
   ```bash
   sudo cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F)
   ```
3. Убедитесь, что есть доступ через консоль гипервизора/провайдера на случай полной блокировки.

## SSH

```bash
sudo sshd -t                      # проверка синтаксиса: должна молчать
sudo systemctl reload ssh         # (на RHEL-подобных системах: sshd)
# в НОВОМ терминале проверьте вход; только после этого закрывайте старую сессию
```
Если вход не работает — восстановите копию и перезагрузите службу:
```bash
sudo cp -a /etc/ssh/sshd_config.bak.YYYY-MM-DD /etc/ssh/sshd_config && sudo systemctl reload ssh
```
Отключайте `PasswordAuthentication` только после того, как убедились, что вход по ключу работает.
В `configs/sshd_hardened.conf` указано `AllowUsers deploy` — замените на своего пользователя, иначе вы потеряете доступ.

## Параметры ядра (sysctl)

```bash
sudo cp configs/sysctl_hardening.conf /etc/sysctl.d/99-hardening.conf
sudo sysctl --system
scripts/check_sysctl.sh           # убедиться, что значения применились
```
Откат: удалить `/etc/sysctl.d/99-hardening.conf` и перезагрузить систему (или вернуть значения командой `sysctl -w`).

## Файрвол nftables

```bash
sudo nft -c -f configs/nftables_baseline.conf    # проверка без применения
sudo nft -f configs/nftables_baseline.conf
sudo nft flush ruleset                           # экстренный откат (правила снимаются, доступ возвращается)
```
Если SSH работает на нестандартном порту — исправьте `tcp dport 22` в файле до применения.

## Fail2ban

Если вы заблокировали себя сами:
```bash
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip <ваш_адрес>
```
Добавьте свой постоянный адрес в `ignoreip`.

## auditd

Правило `-e 2` делает конфигурацию неизменяемой до перезагрузки — включайте его в последнюю очередь,
когда правила отлажены.
