#!/bin/sh

# Create Samba user
if [ "${SAMBA_USER}" ] && ! grep -s "^${SAMBA_USER}" /etc/passwd; then
	adduser --shell /sbin/nologin --gecos '' --disabled-password "${SAMBA_USER}"
	printf '%s\n%s\n' "${SAMBA_PASS}" "${SAMBA_PASS}" | smbpasswd -s -a "${SAMBA_USER}"
fi

# Start Samba
/usr/sbin/smbd "$@"
