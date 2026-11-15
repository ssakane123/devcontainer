# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Not an application: it defines **Claude Code devcontainers** (Rocky Linux 9 + Python 3.14 + Node 24 + Claude Code + oh-my-claudecode) and the **Squid egress proxy** that restricts their network. There is no build/lint/test suite; "testing" means building the images (CI does this) or reopening the devcontainer. Comments and error messages in the configs are mostly Japanese.

## Commands

- Build the dev image locally (needs the `common` build context):
  `docker buildx build --build-context common=.devcontainer/common .devcontainer/python`
- Build the proxy image: `docker build .devcontainer/proxy` (its Dockerfile runs `squid -k parse` and fails on a bad `squid.conf`)
- Reclaim Docker disk: `scripts/cleanup.sh` (prunes containers/images/builder cache/networks; destructive)

## Architecture

**Two devcontainer variants** share one image definition (`.devcontainer/python/Dockerfile`):
- `python/devcontainer.json` — single container, direct network access.
- `python-egress/` — Compose stack: `dev` sits only on an `internal: true` network and reaches the internet solely through the `proxy` (Squid) service via `HTTP(S)_PROXY`. `dev` waits on the proxy healthcheck.

**`.devcontainer/common/`** holds everything shared and is injected into the Dockerfile as the named build context `common` (`COPY --from=common ...`). It is set via `--build-context` in `devcontainer.json`, `additional_contexts` in `compose.yaml`, and `build-contexts` in CI — keep all three in sync if you rename it.
- `install-*.sh` pin tool versions (`CLAUDE_CODE_VERSION`, `OMC_VERSION`, `NODE_MAJOR`); version bumps are done by editing these. `install-claude-code.sh` fails the build if the installed version differs from the pin.
- `managed-settings.json` → `/etc/claude-code/managed-settings.json` (enforced policy: model, permission allow/ask/deny, `git push` denied, managed-only hooks/MCP). `settings.json` → `/etc/claude-code-defaults/settings.json`, symlinked to `~/.claude/settings.json` by `post-create.sh`. Change the model in **both** files (recent commits did exactly this).
- `post-create.sh` runs `omc setup` with `omc-bind-mount-rename-shim.js` preloaded; the shim falls back to in-place writes when atomic renames hit EBUSY/EXDEV on the bind-mounted `~/.claude/CLAUDE.md`. Add other per-file bind-mount targets to its `BIND_MOUNT_TARGETS` set.
- `claudex` wraps `claude` and requires the CLIProxyAPI client key bind-mounted from the host.

**Host dependencies**: both variants bind-mount files from the host's `~/.claude/` (`CLAUDE.md`, `.mcp.json`, `cliproxyapi/cliproxy-client-key`) and `~/.config/git/ignore`; the compose file uses `${HOME:?}` so it fails if any is unset. The `claude-code-config` and `claude-code-npm-cache` named volumes persist state across rebuilds.

**Egress proxy** (`.devcontainer/proxy/`): `squid.conf` allows CONNECT on 443 only to exact FQDNs in `allowlist.txt` (shared) plus `allowlist.local.txt` (per-repo; `templates/allowlist.local.txt` is bind-mounted over the image default). Gotchas:
- Local allowlist entries must be exact FQDNs — no leading dot, scheme, port, or IP.
- The compose healthcheck requires the deny page to contain `X-DEVCONTAINER-EGRESS-DENIED` (in `ERR_DEVCONTAINER_EGRESS`); the proxy Dockerfile fails the build if it is removed.
- `pid_filename none` in `squid.conf` must stay or the devcontainer won't open.
- Plain HTTP is allowed only to `host.docker.internal:18317` (Claudex/CLIProxyAPI).
- Never put real allowlist entries in `allowlist.local.default.txt`.

## CI / image versioning

`.github/workflows/devcontainer-images.yml` builds only changed images (path filters) on linux/arm64 and pushes to `ghcr.io/<owner>/devcontainer-<name>:<version>` on `main`; PRs build without pushing. Tags come from integer-only version files: `IMAGE_VERSION` (python image) and `PROXY_IMAGE_VERSION` (proxy) — bump the number for breaking changes. The `python` filter also triggers on any change under `common/`. Adding a new image requires editing the filters, `changes.outputs`, and copying a job, as described in the workflow header comment. Base images (`ghcr.io/ssakane123/python`, `rocky9`) are arm64-only and live in other repos.
