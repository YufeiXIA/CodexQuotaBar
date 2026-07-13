# CodexQuotaBar

A native macOS menu-bar dashboard for the usage limits of the Codex account
signed in on the current Mac. It displays the remaining percentage, an adaptive
bar chart, the reset countdown, plan, extra credits, reset-card count, and any
additional model-specific limits. If the official response includes a reset-card
expiry, the dashboard also shows its countdown; otherwise it explicitly marks
the expiry as unavailable rather than guessing.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-000000?logo=apple)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)

## Requirements

- macOS 13 or newer
- Xcode Command Line Tools (`xcode-select --install`)
- Codex CLI or Codex desktop app signed in on the same Mac; the app reads the
  standard `~/.codex/auth.json` login state at runtime

No OpenAI API key is required. Credentials stay on the Mac: the app reads the
existing Codex login token only to request the official usage endpoint over
HTTPS. It does not store, log, or upload the token anywhere else.

## Install

```sh
git clone https://github.com/YOUR_GITHUB_USERNAME/CodexQuotaBar.git
cd CodexQuotaBar
make install
```

`make install` builds an ad-hoc-signed local app, copies it to
`~/Applications/CodexQuotaBar.app`, starts it, and configures it to launch at
login. The menu-bar icon shows the remaining percentage; click it for the
dashboard. Usage refreshes every five minutes and can also be refreshed from
the menu.

## Remove

```sh
make uninstall
```

## Build only

```sh
make build
open build/CodexQuotaBar.app
```

## Notes

- The app displays only rate-limit windows returned by the account's current
  official usage response. It does not assume a legacy five-hour window.
- A user must be signed in to Codex locally. If the usage request cannot be
  completed, the menu reports the error without exposing credentials.
- This project is an independent local utility and is not affiliated with or
  endorsed by OpenAI.
