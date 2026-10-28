FROM ghcr.io/ssakane123/python:3.14

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# Install Node.js
ARG NODE_MAJOR=24
ENV NPM_CONFIG_PREFIX=/usr
COPY --from=common install-node.sh /tmp/install-node.sh
RUN bash /tmp/install-node.sh

# Install base dependencies
COPY --from=common install-base.sh /tmp/install-base.sh
RUN USERNAME=${USERNAME} USER_UID=${USER_UID} USER_GID=${USER_GID} \
        bash /tmp/install-base.sh \
 && rm -f /tmp/install-base.sh

# Install OMC (oh-my-claude-sisyphus)
COPY --from=common install-omc.sh /tmp/install-omc.sh
RUN bash /tmp/install-omc.sh

USER ${USERNAME}
ENV HOME=/home/${USERNAME}
ENV PATH=/home/${USERNAME}/.local/bin:${PATH}
WORKDIR ${HOME}

# Install Claude Code CLI
COPY --from=common install-claude-code.sh /tmp/install-claude-code.sh
RUN bash /tmp/install-claude-code.sh

# Install uv
ARG UV_VERSION=0.11.11
# PATH 環境変数を書き換えないようにする
ENV UV_NO_MODIFY_PATH=1
RUN curl -fsSL https://astral.sh/uv/${UV_VERSION}/install.sh | sh

USER root
RUN install -d -m 755 /etc/claude-code /etc/claude-code-defaults /usr/local/share/devcontainer /usr/local/bin
COPY --from=common .zshrc /home/${USERNAME}/.zshrc
COPY --from=common post-create.sh /usr/local/share/devcontainer/post-create.sh
COPY --from=common omc-bind-mount-rename-shim.js /usr/local/share/devcontainer/omc-bind-mount-rename-shim.js
COPY --from=common settings.json /etc/claude-code-defaults/settings.json
COPY --chmod=0644 --from=common managed-settings.json /etc/claude-code/managed-settings.json
COPY --chmod=0755 --from=common claudex /usr/local/bin/claudex
RUN chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.zshrc \
 && chmod +x /usr/local/share/devcontainer/post-create.sh

USER ${USERNAME}
