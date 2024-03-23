ARG BASE_IMAGE=library/debian:stable-slim

FROM docker.io/${BASE_IMAGE}

RUN \
  apt-get update && \
  env DEBIAN_FRONTEND=noninteractive \
  apt-get install -y --no-install-recommends samba samba-vfs-modules smbclient \
  -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/*

COPY rootfs/ /

EXPOSE 445/tcp

VOLUME /home /data

HEALTHCHECK --interval=1m --timeout=15s \
  CMD smbclient -L '\\127.0.0.1' -U '%' -m SMB3 >/dev/null

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--foreground", "--debug-stdout", "--no-process-group", "--debuglevel=1"]
