#!/bin/bash

# Executable locations
# We're specifying the full paths here for security reasons - you'll need to edit these if you have them installed to a different directory
# (an easy way to find where you have them installed is via the `which` command - ex. `which awk`)
AWK='/usr/bin/awk'
CP='/usr/bin/cp'
CURL='/usr/bin/curl'
CUT='/usr/bin/cut'
ECHO='/usr/bin/echo'
GREP='/usr/bin/grep'
HEAD='/usr/bin/head'
LN='/usr/bin/ln'
MKDIR='/usr/bin/mkdir'
RM='/usr/bin/rm'
RUN0='/usr/bin/run0'
SHA512SUM='/usr/bin/sha512sum'
SUDO='/usr/bin/sudo'
TAR='/usr/bin/tar'

if [[ -f "${RUN0}" ]]; then
    ROOT="${RUN0}"
elif [[ -f "${SUDO}" ]]; then
    ROOT="${SUDO}"
else
    "${ECHO}" 'Sorry, only run0 and sudo are supported at this time.'
    exit 1
fi

# Set default curl flags
CURL_FLAGS='--doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error'

# Set variables
FIREFOX_ARCHITECTURE='x86_64'
FIREFOX_URL_ARCHITECTURE='linux64'
FIREFOX_LOCALE='en-US'
FIREFOX_DIR='/opt/firefox'
FIREFOX_URL="https://download.mozilla.org/?product=firefox-latest-ssl&os=${FIREFOX_URL_ARCHITECTURE}&lang=${FIREFOX_LOCALE}"
BASE_URL='https://ftp.mozilla.org/pub/firefox/releases'
CHECKSUMS_BASE_URL='https://productdelivery.mozilla-backup.org/pub/firefox/releases'
CHECKSUMS_URL='SHA512SUMS'
LATEST_VERSION=$("${CURL}" ${CURL_FLAGS} -s "${FIREFOX_URL}" | "${GREP}" -oP 'https://download-installer\.cdn\.mozilla\.net/pub/firefox/releases/\K[0-9]+\.[0-9]+(\.[0-9]+)?')

# Check if Firefox is already installed
if [ -d "${FIREFOX_DIR}" ]; then
    "${ECHO}" "Firefox is already installed at ${FIREFOX_DIR}."
    exit 1
fi

"${ECHO}" "Installing Firefox ${LATEST_VERSION}..."

# Download the SHA512 checksums
CHECKSUMS_FILE="${CHECKSUMS_BASE_URL}/${LATEST_VERSION}/${CHECKSUMS_URL}"
"${CURL}" ${CURL_FLAGS} --tlsv1.3 -O "${CHECKSUMS_FILE}"

# Download the latest Firefox release
FIREFOX_TAR="firefox-${LATEST_VERSION}.tar.xz"
FIREFOX_DOWNLOAD_URL="${BASE_URL}/${LATEST_VERSION}/linux-${FIREFOX_ARCHITECTURE}/${FIREFOX_LOCALE}/${FIREFOX_TAR}"
"${CURL}" ${CURL_FLAGS} --tlsv1.3 -O "${FIREFOX_DOWNLOAD_URL}"

# Verify the checksum for the specific file
CHECKSUM=$("${GREP}" "linux-${FIREFOX_ARCHITECTURE}/${FIREFOX_LOCALE}/${FIREFOX_TAR}" "${CHECKSUMS_URL}" | "${AWK}" '{print $1}')
DOWNLOADED_CHECKSUM=$("${SHA512SUM}" "${FIREFOX_TAR}" | "${AWK}" '{print $1}')

if [ "${CHECKSUM}" != "${DOWNLOADED_CHECKSUM}" ]; then
    "${ECHO}" "Checksum verification failed. Aborting installation..."
    "${RM}" "${FIREFOX_TAR}" "${CHECKSUMS_URL}"
    exit 1
fi

# Extract and install Firefox
"${TAR}" -xf "${FIREFOX_TAR}"
"${ROOT}" "${MKDIR}" -vp "${FIREFOX_DIR}"
"${ROOT}" "${CP}" -v -R firefox/* "${FIREFOX_DIR}/"
"${RM}" -rf firefox "${FIREFOX_TAR}" "${CHECKSUMS_URL}"

# Create a symlink
if ! [ -d "${HOME}/.local/bin" ]; then
    mkdir -vp "${HOME}/.local/bin"
fi

if [[ -f "${HOME}/.local/bin/firefox" ]]; then
    rm -f "${HOME}/.local/bin/firefox"
fi
"${LN}" -s "${FIREFOX_DIR}/firefox" "${HOME}/.local/bin/firefox"

# Add the desktop file
"${CURL}" ${CURL_FLAGS} --tlsv1.3 --cert-status -O "https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop"
if ! [ -d "${HOME}/.local/share/applications" ]; then
    mkdir -vp "${HOME}/.local/share/applications"
fi
"${CP}" -v firefox.desktop "${HOME}/.local/share/applications/"
"${RM}" -f firefox.desktop

"${ECHO}" "Firefox ${LATEST_VERSION} has been installed."
