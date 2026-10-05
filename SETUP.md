# SETUP: установка харнеса для Claude Code

Эта инструкция написана для Claude Code. Человеку достаточно написать в Claude Code:

> Действуй по инструкции https://raw.githubusercontent.com/SALUTme/claude-harness-starter/main/SETUP.md — настрой мой харнес.

Работает на Mac. На Windows 10 и 11 — бета-версия.

---

## Для Claude: как выполнять

- Иди по шагам строго по порядку. Следующий шаг начинай только после проверки предыдущего.
- Общайся на языке пользователя, простыми словами, без жаргона. Пользователь может не быть программистом.
- Перед каждой установкой одной фразой скажи, что ставишь и зачем, и спроси разрешение. Без разрешения не ставь.
- Пароли, ключи и коды не спрашивай и не вводи. Всё, что требует входа в аккаунт или прав администратора, делает сам пользователь: объясни ему, что нажать.
- Не меняй глобальные настройки пользователя (`~/.claude/settings.json`, `~/.claude/CLAUDE.md`), кроме установки плагина на шаге 4.
- Инструкцию можно запускать повторно: всё, что уже установлено, пропускай.
- Если шаг не получается после двух попыток, остановись, объясни, что пошло не так, и предложи варианты.
- В конце покажи короткий отчёт: что установлено, где лежит проект, что делать дальше.

Что будет установлено:

| Что | Версия | Откуда | Зачем |
|---|---|---|---|
| Основа харнеса: навигатор `harness`, подготовка по фазам `harness-setup`, хуки защиты и проверки | 0.3.0 | этот репозиторий | ведёт проект по этапам с проверками |
| `unlazy` | 2.1.0 | github.com/Leonxlnx/unlazy, MIT | условия готовности: ИИ не говорит «готово», пока не проверил |
| `find-skills` | из skills 1.7.0 | github.com/vercel-labs/skills, MIT | находит и ставит новые скилы по ходу работы |
| `skill-creator` | от 2026-10-04 | github.com/anthropics/skills, Apache-2.0 | превращает удачный способ работы в свой скил |
| `deep-research` | от 2026-08-26 | github.com/alirezarezvani/claude-skills, MIT | глубокое исследование: каждый вывод подтверждён тремя независимыми источниками |
| `user-research` | от 2026-10-04 | github.com/anthropics/knowledge-work-plugins, Apache-2.0 | план интервью и опросов |
| `research-synthesis` | от 2026-10-04 | github.com/anthropics/knowledge-work-plugins, Apache-2.0 | сводит интервью, отзывы и данные в выводы |
| Плагин oh-my-claudecode: `deep-interview`, `research`, агенты проверки | 5.6.1 | github.com/Yeachan-Heo/oh-my-claudecode, MIT | интервью, параллельные исследователи, независимая проверка |

Вики по методу Карпати (`raw/` → `wiki/` → правила в `CLAUDE.md`) создаётся на этапе подготовки проекта, отдельно её ставить не нужно.

---

## Шаг 0. Определить систему

Выполни:

```bash
uname -s
```

- `Darwin` — это Mac. Иди к шагу 1M.
- Начинается с `MINGW` или `MSYS` — это Windows с Git Bash. Иди к шагу 1W.
- Команда не сработала, или ты работаешь в PowerShell — это Windows без Git Bash. Иди к шагу 1W.
- `Linux` — скажи, что инструкция проверена на Mac и Windows. Продолжай по шагу 1M, только если пользователь настаивает, и предупреди, что это не проверено.

Скажи пользователю, какую систему ты определил.

## Шаг 1M. Подготовить Mac

```bash
sw_vers -productVersion
for t in git jq node python3 claude curl tar; do printf '%-8s ' "$t"; command -v "$t" || echo "нет"; done
```

- **git.** Выполни `git --version`. Если macOS предлагает установить «инструменты командной строки», попроси пользователя нажать «Установить» в появившемся окне и дождись окончания. Вместе с ними появится и `python3`.
- **jq обязателен.** Без него хуки защиты блокируют все команды и запись файлов. На macOS 15 и новее он уже есть. Если его нет: при наличии Homebrew (`command -v brew`) предложи `brew install jq`. Если Homebrew нет, остановись и предложи пользователю обновить macOS до версии 15 или установить Homebrew с сайта brew.sh (это он делает сам).
- **node** нужен плагину oh-my-claudecode и скилу `find-skills`. Если его нет: при наличии Homebrew предложи `brew install node`. Иначе попроси пользователя скачать установщик LTS с сайта nodejs.org и установить его.
- **claude** нужен для установки плагина на шаге 4. Если команды нет, это не ошибка, на шаге 4 есть другой путь.

**Проверка:** `git --version`, `jq --version`, `node --version`, `python3 --version` отвечают. Иди к шагу 2.

## Шаг 1W. Подготовить Windows (бета)

Харнесу на Windows нужны четыре программы:

| Программа | Зачем |
|---|---|
| Git for Windows | даёт Git Bash: на нём работают хуки защиты, и через него Claude Code выполняет команды |
| jq | хуки читают через него данные; без него защита блокирует всю работу |
| Node.js LTS | нужен плагину oh-my-claudecode и скилу `find-skills` |
| Python 3 | хук защиты проверяет им правки настроек |

1. Проверь, что уже есть. В Git Bash:

   ```bash
   for t in git jq node python claude; do printf '%-7s ' "$t"; command -v "$t" || echo "нет"; done; python --version 2>&1
   ```

   В PowerShell:

   ```powershell
   foreach ($t in 'git','jq','node','python','claude','winget') { "{0,-7} {1}" -f $t, ((Get-Command $t -ErrorAction SilentlyContinue).Source) }; python --version
   ```

   Python считается установленным, только если `python --version` печатает `Python 3...`. Если открывается Microsoft Store или ничего не печатается, его нет.

2. Если всё есть, иди к шагу 2.

3. Если чего-то нет, поставь через `winget`, только недостающее. Скажи пользователю, что команды принимают лицензии этих программ, и спроси разрешение. Установка Git попросит подтвердить права администратора: пользователь нажимает «Да» в окне Windows.

   ```powershell
   winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements
   winget install --id jqlang.jq -e --source winget --accept-source-agreements --accept-package-agreements
   winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-source-agreements --accept-package-agreements
   winget install --id Python.Python.3.13 -e --source winget --accept-source-agreements --accept-package-agreements
   ```

   Если `winget` нет, попроси пользователя обновить «Установщик приложений» (App Installer) в Microsoft Store или скачать программы с сайтов git-scm.com, jqlang.org, nodejs.org и python.org. При установке Python отметить «Add python.exe to PATH».

4. **Обязательный перезапуск.** Новые программы и Git Bash Claude Code увидит только после перезапуска. Скажи пользователю:
   1. полностью закрыть Claude Code (приложение или окно терминала);
   2. открыть его снова;
   3. отправить ту же фразу: «Действуй по инструкции … — настрой мой харнес».

   На этом закончи. При повторном запуске проверка пройдёт и установка продолжится.

**Проверка (при повторном запуске):** `uname -s` начинается с `MINGW`, `git`, `jq`, `node` и `python` отвечают на `--version`. Если Claude Code всё ещё работает в PowerShell, хотя Git установлен, попроси пользователя добавить в настройки Claude Code переменную `CLAUDE_CODE_GIT_BASH_PATH` со значением `C:\Program Files\Git\bin\bash.exe` и перезапустить.

## Шаг 2. Выбрать название и папку проекта

Спроси пользователя:

1. Как назвать проект. Предложи короткое название латиницей через дефис, например `market-research`.
2. Где его создать. По умолчанию `~/Documents/Claude-projects/<название>` (на Windows это папка «Документы» пользователя).

Проверь, что такой папки ещё нет: `test ! -e "<путь>" && echo свободно`. Если есть, предложи другое имя.

## Шаг 3. Скачать основу и создать проект

Аккаунт на GitHub не нужен. Команды одинаковые для Mac и Windows (Git Bash). Подставь путь из шага 2:

```bash
P="$HOME/Documents/Claude-projects/<название>"
mkdir -p "$(dirname "$P")"
TMP=$(mktemp -d)
curl -fsSL https://github.com/SALUTme/claude-harness-starter/archive/refs/heads/main.tar.gz | tar -xz -C "$TMP"
mv "$TMP"/claude-harness-starter-main "$P"
rmdir "$TMP"
cd "$P"
sed -i.bak 's/"template": true/"template": false/' .harness/source.json && rm .harness/source.json.bak
git init -q
git add -A
U="${USER:-${USERNAME:-user}}"
git -c user.name="$U" -c user.email="$U@localhost" commit -qm "Старт проекта из claude-harness-starter"
```

Строка с `sed` помечает папку как проект, а не как основу. Без неё навигатор откажется готовить проект.

**Проверка:**

```bash
cd "$P" && ls .claude/skills && grep '"template"' .harness/source.json && git log --oneline | head -1
```

Должны быть видны скилы `deep-research`, `find-skills`, `harness`, `harness-setup`, `research-synthesis`, `skill-creator`, `unlazy`, `user-research`, строка `"template": false` и один коммит.

## Шаг 4. Установить плагин oh-my-claudecode

Сначала проверь, не стоит ли он уже: `claude plugin list 2>/dev/null | grep -A3 oh-my-claudecode`. Если стоит версия 5.6.1 или новее, пропусти шаг.

Если команда `claude` есть:

```bash
claude plugin marketplace add "https://github.com/Yeachan-Heo/oh-my-claudecode.git#v5.6.1"
claude plugin install oh-my-claudecode@omc
claude plugin list
```

Если команды `claude` нет, попроси пользователя ввести в чат Claude Code по очереди две команды:

```text
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode.git#v5.6.1
/plugin install oh-my-claudecode@omc
```

Если и это не сработало, не останавливайся: харнес работает и без плагина, интервью и проверку тогда ведёт сам Claude. Запиши это в отчёт.

Команду `/omc-setup` из документации плагина запускать **не нужно**: она переписывает глобальные настройки, харнесу это не требуется.

**Проверка:** в `claude plugin list` есть `oh-my-claudecode@omc`, версия 5.6.1, статус enabled.

## Шаг 5. Проверить защиту

```bash
cd "$P" && bash .claude/hooks/smoke-test.sh | tail -3
```

**Проверка:** в итоге `FAIL=0`. На Windows (бета) при ошибках не исправляй хуки сам: покажи пользователю строки с `FAIL` и попроси отправить их автору харнеса. Установку продолжай.

## Шаг 6. Перезапуск и первый запуск

Новые скилы, хуки и плагин подхватываются только в новой сессии. Скажи пользователю, что делать, и на этом закончи свою работу:

1. Закрыть текущую сессию.
2. Открыть Claude Code **в папке проекта** `<путь из шага 2>`:
   - в приложении Claude: вкладка Code → новая сессия → выбрать эту папку;
   - в терминале: `cd "<путь>" && claude`.
3. Если Claude спросит, доверять ли папке, ответить «да».
4. Написать «привет».

Первой строкой Claude должен увидеть статус «Это исследовательский проект». Дальше навигатор сам скажет, на каком этапе проект, и предложит следующий шаг. Подготовка начнётся с интервью: нужно просто отвечать на вопросы.

## Итоговый отчёт пользователю

Коротко, простыми словами:

- какая система и где лежит проект;
- что установлено (таблица из начала, отметить пропущенное и почему);
- результат автотеста защиты;
- шаги перезапуска из шага 6.
