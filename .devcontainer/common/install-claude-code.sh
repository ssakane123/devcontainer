#!/bin/bash
set -euo pipefail

: "${HOME:?must be set by the Dockerfile ENV HOME line}"

CLAUDE_CODE_VERSION=2.1.310

curl -fsSL https://claude.ai/install.sh | bash -s -- "${CLAUDE_CODE_VERSION}"

version_line="$("${HOME}/.local/bin/claude" --version)"
installed_version="${version_line%% *}"
if [ "${installed_version}" != "${CLAUDE_CODE_VERSION}" ]; then
    echo "FATAL: claude version pin not honoured." >&2
    echo "  requested: ${CLAUDE_CODE_VERSION}" >&2
    echo "  installed: ${installed_version}" >&2
    echo "  The install.sh argv contract changed; see docs/design.md §2.4." >&2
    exit 1
fi
echo "claude ${installed_version} installed (pinned)"
