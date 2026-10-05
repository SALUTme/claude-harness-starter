#!/usr/bin/env bash
# harness | переходник хуков обвязки для Codex. Подключается из .codex/hooks.json: codex-adapter.sh <хук>
# Codex шлёт хукам почти тот же JSON, что Claude Code, но есть два отличия:
# 1. Файлы он правит инструментом apply_patch: путь и текст лежат в патче в tool_input.command.
#    Переходник разбирает патч и показывает хуку каждый файл как запись Write.
# 2. Решение «ask» Codex не поддерживает: он считает хук сломанным и выполняет действие.
#    Переходник превращает «ask» в запрет с объяснением, что делать.
set -u

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
hook="${1:-}"
case "$hook" in
  harness-status|block-dangerous|commit-gate|secret-guard|after-edit-check|stop-gate) ;;
  *) echo "harness: codex-adapter: неизвестный хук «$hook»" >&2; exit 0 ;;
esac

if [ "$hook" = "harness-status" ]; then
  # SessionStart: статус уходит в контекст модели. Обычный текст, который начинается с «[», Codex читает как JSON
  # и считает хук сломанным, поэтому статус заворачивается в additionalContext.
  cat >/dev/null
  status=$(bash "$HOOK_DIR/harness-status.sh" 2>/dev/null)
  [ -z "$status" ] && exit 0
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg c "$status" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
  else
    printf 'harness: %s\n' "$status"
  fi
  exit 0
fi

input=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  # Без jq хуки защиты сами блокируют работу и объясняют почему
  printf '%s' "$input" | bash "$HOOK_DIR/$hook.sh"
  exit $?
fi

cwd=$(jq -r '.cwd // empty' <<<"$input")
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
export CLAUDE_PROJECT_DIR

ASK_NOTE="Codex не умеет спрашивать подтверждение через хук, поэтому действие остановлено. Покажи пользователю, что и зачем хочешь сделать, и попроси выполнить это самому."

# Печатает решение хука для Codex. $1 код выхода хука, $2 его вывод.
emit() {
  local rc="$1" out="$2" reason
  if [ "$rc" -eq 2 ]; then
    return 2
  fi
  if printf '%s' "$out" | grep -q '"permissionDecision": *"ask"'; then
    reason=$(jq -r '.hookSpecificOutput.permissionDecisionReason // "нужно подтверждение человека"' <<<"$out" 2>/dev/null)
    jq -n --arg r "$reason $ASK_NOTE" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
    return 0
  fi
  [ -n "$out" ] && printf '%s\n' "$out"
  return "$rc"
}

# Вызывает хук с данным входом. Ошибки хука идут в stderr Codex.
call() { # $1 вход
  local out rc
  out=$(printf '%s' "$1" | bash "$HOOK_DIR/$hook.sh"); rc=$?
  emit "$rc" "$out"
}

tool=$(jq -r '.tool_name // ""' <<<"$input")

if [ "$tool" != "apply_patch" ] || { [ "$hook" != "secret-guard" ] && [ "$hook" != "after-edit-check" ]; }; then
  call "$input"
  exit $?
fi

# --- apply_patch: каждый файл патча проверяется отдельно
patch=$(jq -r '.tool_input.command // .tool_input.input // .tool_input.patch // empty' <<<"$input")
session=$(jq -r '.session_id // "nosession"' <<<"$input")
[ -z "$patch" ] && exit 0

# Файлы патча: строки «F<TAB>путь», затем добавленные строки «C<TAB>текст»
records=$(printf '%s\n' "$patch" | awk '
  /^\*\*\* (Add|Update|Delete) File: / { sub(/^\*\*\* (Add|Update|Delete) File: /, ""); print "F\t" $0; next }
  /^\*\*\* Move to: /                   { sub(/^\*\*\* Move to: /, "");                   print "F\t" $0; next }
  /^\*\*\* /                            { next }
  /^\+/                                 { print "C\t" substr($0, 2); next }
')

last_out=""; worst_rc=0
check_file() { # $1 путь, $2 текст
  local p="$1" body out rc
  case "$p" in /*|[A-Za-z]:*) ;; *) p="$PWD/$p" ;; esac
  body=$(jq -n --arg p "$p" --arg c "$2" --arg s "$session" --arg t "$hook" \
    'if $t == "secret-guard" then {session_id:$s, tool_name:"Write", tool_input:{file_path:$p, content:$c}}
     else {session_id:$s, tool_name:"Write", tool_input:{file_path:$p}} end')
  out=$(printf '%s' "$body" | bash "$HOOK_DIR/$hook.sh"); rc=$?
  if [ "$hook" = "secret-guard" ]; then
    if [ "$rc" -eq 2 ] || printf '%s' "$out" | grep -Eq '"permissionDecision": *"(deny|ask)"'; then
      emit "$rc" "$out"; exit $?
    fi
  else
    [ -n "$out" ] && last_out="$out"
    [ "$rc" -ne 0 ] && worst_rc=$rc
  fi
}

cur=""; content=""; have=0
while IFS= read -r line; do
  case "$line" in
    F$'\t'*) [ "$have" = 1 ] && check_file "$cur" "$content"; cur="${line#F$'\t'}"; content=""; have=1 ;;
    C$'\t'*) content="${content}${line#C$'\t'}"$'\n' ;;
  esac
done <<<"$records"
[ "$have" = 1 ] && check_file "$cur" "$content"

[ -n "$last_out" ] && printf '%s\n' "$last_out"
exit "$worst_rc"
