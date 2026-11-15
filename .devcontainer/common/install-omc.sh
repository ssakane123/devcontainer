#!/bin/bash
set -euo pipefail

OMC_VERSION=5.8.0

npm install -g "oh-my-claude-sisyphus@${OMC_VERSION}"

echo "omc ${OMC_VERSION} installed (pinned)"
