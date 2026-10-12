# Если у вас Windows

Харнес работает на Windows 10 и 11 через Git Bash из Git for Windows. Установщик сам ставит всё нужное. Если что-то пошло не так, найдите свою ситуацию ниже.

| Что происходит | Что сделать |
|---|---|
| Codex не может выполнить ни одной команды: `setup refresh had errors`, `Failed to create unified exec process` или `CreateProcessSecurityEnvironment failed` | Это ошибка песочницы самого Codex на Windows, харнес тут ни при чём. 1) Обновите Codex и перезапустите. 2) Если не помогло, добавьте в файл `%USERPROFILE%\.codex\config.toml` две строки и перезапустите Codex: `[windows]` и `sandbox = "unelevated"`. Песочница станет слабее. 3) Если и это не помогло, выполняйте команды установки сами в Git Bash, а агент будет подсказывать их по одной. |
| Агент работает в PowerShell, хотя Git for Windows установлен | Полностью закройте агента и откройте снова. Если не помогло, в Claude Code добавьте в настройки переменную `CLAUDE_CODE_GIT_BASH_PATH` со значением `C:\Program Files\Git\bin\bash.exe`. |
| Агент пишет, что хук не запустился или что «в WSL нет Bash» | WSL ставить не нужно. В папке проекта, в Git Bash, выполните `git config alias.harness-hook "!$(command -v bash) .claude/hooks/codex-adapter.sh"` и перезапустите агента. Проверка: `git harness-hook harness-status < /dev/null` печатает статус проекта. |
| Вместо Python открывается Microsoft Store | Установите Python: `winget install --id Python.Python.3.13 -e`. Затем в «Параметры → Приложения → Дополнительные параметры приложений → Псевдонимы выполнения приложений» выключите `python.exe` и `python3.exe`. Перезапустите агента. |
| Автотест защиты показывает `FAIL` | Обновите программы: `winget upgrade --id Git.Git -e`, `winget upgrade --id jqlang.jq -e`, `winget upgrade --id Python.Python.3.13 -e`. Перезапустите агента и повторите шаг 5 установки. Если ошибки остались, защита работает не полностью: не храните пароли и ключи в папке проекта и внимательно читайте, что агент просит подтвердить. |
| В Codex не видны скилы проекта | Скилы для Codex лежат в `.agents/skills`, на Windows это копия `.claude/skills`. Если её нет или скил менялся, в Git Bash в папке проекта выполните `rm -rf .agents/skills && cp -R .claude/skills .agents/skills`. |
| Папку проекта перенесли или переименовали | Откройте агента в новом месте и напишите «привет». Если хуки не запускаются, выполните строку с `git config alias.harness-hook` из третьей строки таблицы. |
