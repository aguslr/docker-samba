#!/bin/sh

# Create Samba users
if [ -f "${SAMBA_USERSFILE}" ]; then
	# Read users file line by line
	while read -r line; do
		# Parse line for user information
		printf '%s' "${line}" | grep -v '^\s*#' | \
			while IFS=':' read -r uid name group hash; do
			# Add user to system
			adduser --shell /sbin/nologin --uid "${uid}" --ingroup "${group}" --gecos '' --no-create-home --disabled-password "${name}"
			# Add user to Samba without a password
			smbpasswd -a -n "${name}"
			# Set password using hash and enable user
			pdbedit -u "${name}" --set-nt-hash "${hash}" -c "[ ]"
		done
	done < "${SAMBA_USERSFILE}"
elif [ -f "${SAMBA_PASSWDFILE}" ]; then
	# Read password file line by line
	while read -r line; do
		# Parse line for user information
		printf '%s' "${line}" | grep -v '^\s*#' | \
			while IFS=':' read -r name uid lanman nt flags mtime; do
			# Add user to system
			adduser --shell /sbin/nologin --uid "${uid}" --ingroup 'users' --gecos '' --no-create-home --disabled-password "${name}"
		done
	done < "${SAMBA_PASSWDFILE}"
	# Import password file
	pdbedit -i smbpasswd:"${SAMBA_PASSWDFILE}"
elif [ "${SAMBA_USER}" ] && ! grep -q -s "^${SAMBA_USER}" /etc/passwd; then
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
