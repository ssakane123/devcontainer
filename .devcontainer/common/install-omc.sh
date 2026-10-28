#!/bin/bash
set -euo pipefail

OMC_VERSION=5.7.9

npm install -g "oh-my-claude-sisyphus@${OMC_VERSION}"

echo "omc ${OMC_VERSION} installed (pinned)"
