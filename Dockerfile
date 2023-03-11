ARG BASE_IMAGE=alpine:latest

FROM docker.io/${BASE_IMAGE}

RUN \
  apk add --update --no-cache samba \
  && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
COPY smb.conf /etc/samba/smb.conf

EXPOSE 445/tcp

VOLUME /home /data

HEALTHCHECK --interval=1m --timeout=15s \
  CMD smbclient -L '\\127.0.0.1' -U '%' -m SMB3 >/dev/null

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--foreground", "--log-stdout", "--no-process-group", "--debuglevel=1"]
