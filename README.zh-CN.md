# CodexQuotaBar

> [English](README.md) | 简体中文

一个 macOS 原生菜单栏仪表盘，用于展示当前 Mac 上已登录 Codex 账户的用量限额。它显示剩余百分比、自适应条形图、重置倒计时、套餐、额外积分、reset-card 数量，以及任何额外的模型专属限额。如果官方响应里包含 reset-card 过期时间，仪表盘也会显示其倒计时；否则它会明确标注"过期时间不可用"，而不是去猜测。

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-000000?logo=apple)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)

## 环境要求

- macOS 13 或更高版本
- Xcode Command Line Tools（`xcode-select --install`）
- 在同一台 Mac 上已登录的 Codex CLI 或 Codex 桌面应用；应用运行时读取标准的 `~/.codex/auth.json` 登录状态

不需要 OpenAI API key。凭据留在 Mac 本机：应用读取已有的 Codex 登录 token，仅用于通过 HTTPS 请求官方用量接口。它不会在其他任何地方存储、记录或上传该 token。

## 安装

```sh
git clone https://github.com/YOUR_GITHUB_USERNAME/CodexQuotaBar.git
cd CodexQuotaBar
make install
```

`make install` 会构建一个本地 ad-hoc 签名的应用，复制到 `~/Applications/CodexQuotaBar.app`，启动它，并配置为登录时自启动。菜单栏图标显示剩余百分比；点击它打开仪表盘。用量每五分钟刷新一次，也可以从菜单手动刷新。

## 卸载

```sh
make uninstall
```

## 仅构建

```sh
make build
open build/CodexQuotaBar.app
```

## 说明

- 应用只展示当前账户官方用量响应中返回的限流窗口，不假定传统的五小时窗口。
- 用户必须已在本机登录 Codex。如果用量请求无法完成，菜单会报告错误，但不会暴露凭据。
- 本项目是一个独立的本地工具，与 OpenAI 无关联，也未获得 OpenAI 的背书。
