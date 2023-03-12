#!/bin/sh

# Create Samba user
if [ "${SAMBA_USER:=smbuser}" ] && ! grep -s "^${SAMBA_USER}" /etc/passwd; then
	adduser --shell /sbin/nologin --uid "${SAMBA_UID:-11000}" --no-create-home --disabled-password "${SAMBA_USER}"
	[ -z "${SAMBA_PASS}" ] && SAMBA_PASS=$(date +%s | sha256sum | base64 | head -c 32)
	printf '%s\n%s\n' "${SAMBA_PASS}" "${SAMBA_PASS}" | smbpasswd -s -a "${SAMBA_USER}" && \
	printf 'Password for %s is %s\n' "${SAMBA_USER}" "${SAMBA_PASS}"
fi

# Start Samba
/usr/sbin/smbd "$@"
