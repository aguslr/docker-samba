#!/bin/sh

# Create Samba user
if [ "${SAMBA_USER:=smbuser}" ] && ! grep -q -s "^${SAMBA_USER}" /etc/passwd; then
	# Generate random password
	[ -z "${SAMBA_PASS}" ] && \
		SAMBA_PASS=$(date +%s | sha256sum | base64 | head -c 32) && gen_pass=1
	# Add user to system
	adduser --shell /sbin/nologin --uid "${SAMBA_UID:-11000}" --no-create-home --disabled-password "${SAMBA_USER}"
	# Add user to Samba
	if printf '%s\n%s\n' "${SAMBA_PASS}" "${SAMBA_PASS}" \
		| smbpasswd -s -a "${SAMBA_USER}" && [ "${gen_pass}" -eq 1 ]; then
		printf 'Password for %s is %s\n' "${SAMBA_USER}" "${SAMBA_PASS}"
	fi
fi

# Start Samba
/usr/sbin/smbd "$@"
