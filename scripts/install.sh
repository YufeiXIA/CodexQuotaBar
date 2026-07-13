#!/bin/zsh
set -euo pipefail

if [[ $# -ne 1 ]]; then
  print -u2 "Usage: $0 path/to/CodexQuotaBar.app"
  exit 64
fi

SOURCE_APP=${1:A}
SCRIPT_DIR=${0:A:h}
APP_NAME="CodexQuotaBar.app"
INSTALL_DIR="$HOME/Applications"
APP_PATH="$INSTALL_DIR/$APP_NAME"
LABEL="com.codexquotabar.app"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"
USER_ID=$(id -u)

[[ -d "$SOURCE_APP" ]] || { print -u2 "App bundle not found: $SOURCE_APP"; exit 66; }
mkdir -p "$INSTALL_DIR" "$HOME/Library/LaunchAgents"
launchctl bootout "gui/$USER_ID" "$PLIST_PATH" 2>/dev/null || true
ditto "$SOURCE_APP" "$APP_PATH"
sed "s|__EXECUTABLE__|$APP_PATH/Contents/MacOS/CodexQuotaBar|" \
  "$SCRIPT_DIR/../Resources/com.codexquotabar.app.plist" > "$PLIST_PATH"

launchctl bootstrap "gui/$USER_ID" "$PLIST_PATH"
launchctl kickstart -k "gui/$USER_ID/$LABEL"
print "Installed $APP_PATH and enabled login launch."
