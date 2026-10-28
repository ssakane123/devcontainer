#!/usr/bin/env bash
# Selected Node.js AppStream installation, shared by the four Pattern X images.
set -euo pipefail

: "${NODE_MAJOR:?must be set by the Dockerfile ARG NODE_MAJOR}"

dnf --refresh -y module reset nodejs
dnf -y module enable "nodejs:${NODE_MAJOR}"
dnf -y --setopt=install_weak_deps=False install nodejs npm
test "$(node -p 'process.versions.node.split(".")[0]')" = "${NODE_MAJOR}"
npm --version
npx --version
test "$(npm config get prefix)" = /usr
test "$(npm root -g)" = /usr/lib/node_modules
dnf clean all
rm -rf /var/cache/dnf
