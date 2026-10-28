#!/bin/bash
set -e
claude --version

NODE_OPTIONS="--require=/usr/local/share/devcontainer/omc-bind-mount-rename-shim.js${NODE_OPTIONS:+ $NODE_OPTIONS}" omc setup

[ -L ~/.claude/settings.json ] || ln -sf /etc/claude-code-defaults/settings.json ~/.claude/settings.json
[ -L ~/.claude.json ] || ln -sf /home/vscode/.claude/_user_config.json /home/vscode/.claude.json
