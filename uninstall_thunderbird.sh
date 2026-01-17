#!/bin/bash

# Executable locations
# We're specifying the full paths here for security reasons - you'll need to edit these if you have them installed to a different directory
# (an easy way to find where you have them installed is via the `which` command - ex. `which awk`)
ECHO='/usr/bin/echo'
READ='/usr/bin/read'
RM='/usr/bin/rm'
RUN0='/usr/bin/run0'
SUDO='/usr/bin/sudo'

if [[ -f "${RUN0}" ]]; then
    ROOT="${RUN0}"
elif [[ -f "${SUDO}" ]]; then
    ROOT="${SUDO}"
else
    "${ECHO}" 'Sorry, only run0 and sudo are supported at this time.'
    exit 1
fi

# Set variables
THUNDERBIRD_DIR='/opt/thunderbird'
THUNDERBIRD_SYMLINK="${HOME}/.local/bin/thunderbird"
THUNDERBIRD_DESKTOP="${HOME}/.local/share/applications/thunderbird.desktop"

# Check if Thunderbird is actually installed
if ! [ -d "${THUNDERBIRD_DIR}" ]; then
    "${ECHO}" "Thunderbird is not installed at ${THUNDERBIRD_DIR}."
    exit 1
fi

"${ECHO}" "Uninstalling Thunderbird..."

# Uninstall Thunderbird
"${ROOT}" "${RM}" -rf "${THUNDERBIRD_DIR}"

# Remove symlink
if [ -f "${THUNDERBIRD_SYMLINK}" ]; then
    "${RM}" -f "${THUNDERBIRD_SYMLINK}"
fi

# Remove desktop file
if [ -f "${THUNDERBIRD_DESKTOP}" ]; then
    "${RM}" -f "${THUNDERBIRD_DESKTOP}"
fi

"${ECHO}" -e "Would you also like to remove your profiles/data (${HOME}/.thunderbird)?";
				select yn in "Yes" "No"; do
					case $yn in
							Yes )
								echo -e "Removing ${HOME}/.thunderbird...";
								"${RM}" -rf "${HOME}/.thunderbird";
								break;;
							No )
								break;;
						esac
					done

"${ECHO}" "Thunderbird has been uninstalled."
