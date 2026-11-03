FROM ghcr.io/ssakane123/rocky9:latest

# ヘルスチェックで grep を利用するため、明示的にインストールする
RUN dnf install -y --setopt=install_weak_deps=False squid curl grep \
 && dnf clean all \
 && rm -rf /var/cache/dnf

COPY squid.conf /etc/squid/squid.conf
COPY allowlist.txt /etc/squid/allowlist.txt

COPY allowlist.local.default.txt /etc/squid/allowlist.local.txt

RUN install -d -o squid -g squid -m 750 /var/log/squid

COPY ERR_DEVCONTAINER_EGRESS /usr/share/squid/errors/templates/ERR_DEVCONTAINER_EGRESS

# COPY proxy-entrypoint /usr/local/bin/proxy-entrypoint
# RUN chmod 0755 /usr/local/bin/proxy-entrypoint

RUN if ! grep -q 'X-DEVCONTAINER-EGRESS-DENIED' \
        /usr/share/squid/errors/templates/ERR_DEVCONTAINER_EGRESS; then \
      echo 'FATAL: healthcheck marker X-DEVCONTAINER-EGRESS-DENIED is gone.' >&2; \
      echo '  <lang>-egress/compose.yaml greps for it; without it every devcontainer refuses to open.' >&2; \
      exit 1; \
    fi

RUN squid -k parse

EXPOSE 3128

# ENTRYPOINT ["/usr/local/bin/proxy-entrypoint"]
CMD ["squid", "-N", "-d", "1"]
