#!/bin/bash

# Executable locations
# We're specifying the full paths here for security reasons - you'll need to edit these if you have them installed to a different directory
# (an easy way to find where you have them installed is via the `which` command - ex. `which awk`)
ECHO='/usr/bin/echo'
READ='/usr/bin/read'
RM='/usr/bin/rm'
RUN0='/usr/bin/run0'
SUDO='/usr/bin/sudo'
UPDATE_DESKTOP_DB='/usr/bin/update-desktop-database'

if [[ -f "${RUN0}" ]]; then
    ROOT="${RUN0}"
elif [[ -f "${SUDO}" ]]; then
    ROOT="${SUDO}"
else
    "${ECHO}" 'Sorry, only run0 and sudo are supported at this time.'
    exit 1
fi

# Set variables
FIREFOX_DIR='/opt/firefox'
FIREFOX_SYMLINK="${HOME}/.local/bin/firefox"
FIREFOX_DESKTOP="${HOME}/.local/share/applications/firefox.desktop"

# Check if Firefox is actually installed
if ! [ -d "${FIREFOX_DIR}" ]; then
    "${ECHO}" "Firefox is not installed at ${FIREFOX_DIR}."
    exit 1
fi

"${ECHO}" "Uninstalling Firefox..."

# Uninstall Firefox
"${ROOT}" "${RM}" -rf "${FIREFOX_DIR}"

# Remove symlink
if [ -f "${FIREFOX_SYMLINK}" ]; then
    "${RM}" -f "${FIREFOX_SYMLINK}"
fi

# Remove desktop file
if [ -f "${FIREFOX_DESKTOP}" ]; then
    "${RM}" -f "${FIREFOX_DESKTOP}"
	"${UPDATE_DESKTOP_DB}" "${HOME}/.local/share/applications/"
fi

"${ECHO}" -e "Would you also like to remove your profiles/data (${HOME}/.mozilla)?";
				select yn in "Yes" "No"; do
					case $yn in
							Yes )
								echo -e "Removing ${HOME}/.mozilla...";
								"${RM}" -rf "${HOME}/.mozilla";
								break;;
							No )
								break;;
						esac
					done

"${ECHO}" "Firefox has been uninstalled."
