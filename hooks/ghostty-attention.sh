#!/usr/bin/env bash
# ghostty-attention.sh — Notification contextuelle + switch vers le bon tab Ghostty
#
# Déclenché par les hooks Claude Code : Stop, Notification
# Reçoit le JSON de l'événement sur stdin.
#
# Dépendances : ~/.claude/bin/alerter, osascript, python3

set -euo pipefail

ALERTER="$HOME/.claude/bin/alerter"
GHOSTTY_ICON="/Applications/Ghostty.app/Contents/Resources/Ghostty.icns"
SENDER="com.apple.ScriptEditor2"
MAPPING_FILE="$HOME/.claude/hooks/tab-mapping.conf"

# ─── Parse stdin JSON via python3 (un seul appel) ────────────
INPUT=$(cat)
PARSED=$(python3 -c "
import json, sys, re, shlex
try:
    d = json.loads(sys.argv[1])
except:
    d = {}
def clean(s, mx=200):
    return re.sub(r'[\n\r\t]+', ' ', str(s)).strip()[:mx]
print(shlex.quote(d.get('hook_event_name', 'unknown')))
print(shlex.quote(d.get('cwd', '/tmp')))
print(shlex.quote(clean(d.get('last_assistant_message', ''))))
print(shlex.quote(d.get('notification_type', '')))
print(shlex.quote(clean(d.get('message', ''))))
" "$INPUT" 2>/dev/null) || PARSED="'unknown'
'/tmp'
''
''
''"

EVENT=$(echo "$PARSED" | sed -n '1p' | xargs)
CWD=$(echo "$PARSED" | sed -n '2p' | xargs)
LAST_MSG=$(echo "$PARSED" | sed -n '3p' | xargs)
NOTIF_TYPE=$(echo "$PARSED" | sed -n '4p' | xargs)
NOTIF_MSG=$(echo "$PARSED" | sed -n '5p' | xargs)

# ─── Dériver le nom du projet ─────────────────────────────────
PROJECT_DIR=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
REPO_NAME=$(basename "$PROJECT_DIR")

# ─── Construire le contenu de la notification ─────────────────
case "$EVENT" in
    Stop)
        TITLE="✅ Claude Code"
        SOUND="Glass"
        if [ -n "$LAST_MSG" ]; then
            MESSAGE=$(echo "$LAST_MSG" | cut -c1-120)
            [ ${#LAST_MSG} -gt 120 ] && MESSAGE="${MESSAGE}…"
        else
            MESSAGE="Claude a terminé son travail."
        fi
        ;;
    Notification)
        case "$NOTIF_TYPE" in
            permission_prompt)
                TITLE="🔒 Permission requise"
                SOUND="Ping"
                MESSAGE="${NOTIF_MSG:-Claude a besoin d une permission.}"
                ;;
            idle_prompt)
                TITLE="⏳ En attente"
                SOUND="Tink"
                MESSAGE="${NOTIF_MSG:-Claude attend ta réponse.}"
                ;;
            elicitation_dialog)
                TITLE="❓ Question"
                SOUND="Bottle"
                MESSAGE="${NOTIF_MSG:-Claude te pose une question.}"
                ;;
            *)
                TITLE="🔔 Claude Code"
                SOUND="Glass"
                MESSAGE="${NOTIF_MSG:-Claude a besoin de toi.}"
                ;;
        esac
        ;;
    *)
        TITLE="🔔 Claude Code"
        SOUND="Glass"
        MESSAGE="Événement: ${EVENT}"
        ;;
esac

# ─── Trouver l'index du tab Ghostty ──────────────────────────
# Termes de recherche en cascade
SEARCH_TERMS="$REPO_NAME"
DIR_NAME=$(basename "$CWD")
[ "$DIR_NAME" != "$REPO_NAME" ] && SEARCH_TERMS="$SEARCH_TERMS $DIR_NAME"
if [ -f "$MAPPING_FILE" ]; then
    mapped=$(grep -i "^${REPO_NAME}=" "$MAPPING_FILE" 2>/dev/null | head -1 | cut -d= -f2- || true)
    [ -n "$mapped" ] && SEARCH_TERMS="$SEARCH_TERMS $mapped"
fi

# Récupérer les tabs (un seul appel osascript)
TAB_LIST=$(osascript -e '
tell application "System Events"
    tell process "Ghostty"
        set menuItems to every menu item of menu "Window" of menu bar 1
        set lastSepIdx to 0
        set idx to 0
        repeat with mi in menuItems
            set idx to idx + 1
            try
                if name of mi is missing value then set lastSepIdx to idx
            end try
        end repeat
        set tabIdx to 0
        set output to ""
        set idx to 0
        repeat with mi in menuItems
            set idx to idx + 1
            if idx > lastSepIdx then
                set tabIdx to tabIdx + 1
                try
                    set output to output & tabIdx & "	" & name of mi & linefeed
                end try
            end if
        end repeat
        return output
    end tell
end tell
' 2>/dev/null || echo "")

# Recherche case-insensitive en cascade
TAB_INDEX="0"
TAB_NAME=""
for term in $SEARCH_TERMS; do
    while IFS=$'\t' read -r idx name; do
        [ -z "$idx" ] && continue
        if echo "$name" | grep -qi "$term"; then
            TAB_INDEX="$idx"
            TAB_NAME="$name"
            break 2
        fi
    done <<< "$TAB_LIST"
done

SUBTITLE="${TAB_NAME:-$REPO_NAME}"

# ─── Jouer le son (indépendant de la notification) ────────────
SOUND_FILE="/System/Library/Sounds/${SOUND}.aiff"
[ -f "$SOUND_FILE" ] && afplay "$SOUND_FILE" &

# ─── Envoyer la notification + switch au clic ─────────────────
# nohup + disown pour que le processus survive si Claude Code tue le hook
nohup bash -c "
    result=\$(\"$ALERTER\" \
        --title \"$TITLE\" \
        --subtitle \"$SUBTITLE\" \
        --message \"$MESSAGE\" \
        --actions \"Y aller\" \
        --close-label \"Plus tard\" \
        --sender \"$SENDER\" \
        --app-icon \"$GHOSTTY_ICON\" \
        --group \"claude-attention\" \
        --timeout 30 \
        --json 2>/dev/null) || true

    activation=\$(echo \"\$result\" | python3 -c \"import json,sys; print(json.load(sys.stdin).get('activationType',''))\" 2>/dev/null || echo \"\")

    if [ \"\$activation\" = \"actionClicked\" ] || [ \"\$activation\" = \"contentsClicked\" ]; then
        if [ \"$TAB_INDEX\" != \"0\" ]; then
            osascript \
                -e 'tell application \"Ghostty\" to activate' \
                -e 'delay 0.5' \
                -e 'tell application \"System Events\" to tell process \"Ghostty\" to keystroke \"$TAB_INDEX\" using command down' \
                2>/dev/null
        else
            osascript -e 'tell application \"Ghostty\" to activate' 2>/dev/null
        fi
    fi
" </dev/null >/dev/null 2>&1 &
disown

exit 0
