#!/bin/bash
set -euxo pipefail

: "${USERNAME:?must be set by Dockerfile}"
: "${USER_UID:?must be set by Dockerfile}"
: "${USER_GID:?must be set by Dockerfile}"

# 1. Base packages
dnf install -y --setopt=install_weak_deps=False \
    git \
    curl \
    tar \
    gzip \
    which \
    ca-certificates \
    tmux \
    jq \
    zsh \
    python3.14 \
    python3.14-pip

# 2. git-delta from EPEL 9
dnf install -y epel-release
dnf install -y --enablerepo=epel git-delta
dnf clean all
rm -rf /var/cache/dnf

# 3. Python 3.14 setup and symlinks
[ -x /usr/bin/python3.14 ] || { echo "FATAL: python3.14 did not provide /usr/bin/python3.14"; exit 1; }
[ -x /usr/bin/pip3.14 ]    || { echo "FATAL: python3.14-pip did not provide /usr/bin/pip3.14"; exit 1; }
ln -sf /usr/bin/python3.14 /usr/local/bin/python3
ln -sf /usr/bin/pip3.14    /usr/local/bin/pip3

# 4. User setup and .claude.json symlink
groupadd --gid "${USER_GID}" "${USERNAME}"
useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}"
install -d -o "${USERNAME}" -g "${USERNAME}" "/home/${USERNAME}/.claude"
install -d -o "${USERNAME}" -g "${USERNAME}" "/home/${USERNAME}/.claude/hooks"
install -d -o "${USERNAME}" -g "${USERNAME}" "/home/${USERNAME}/.config"
install -d -o "${USERNAME}" -g "${USERNAME}" "/home/${USERNAME}/.config/git"
install -d -o "${USERNAME}" -g "${USERNAME}" "/home/${USERNAME}/.npm"
install -m 644 -o "${USERNAME}" -g "${USERNAME}" /dev/null "/home/${USERNAME}/.zshrc"
ln -sf "/home/${USERNAME}/.claude/_user_config.json" "/home/${USERNAME}/.claude.json"
chown -h "${USER_UID}:${USER_GID}" "/home/${USERNAME}/.claude.json"
