#!/bin/zsh
set -euo pipefail

LABEL="com.codexquotabar.app"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"
launchctl bootout "gui/$(id -u)" "$PLIST_PATH" 2>/dev/null || true
rm -f "$PLIST_PATH"
rm -rf "$HOME/Applications/CodexQuotaBar.app"
print "CodexQuotaBar removed."
