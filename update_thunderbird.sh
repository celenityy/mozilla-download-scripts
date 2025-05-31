#!/bin/bash

# Executable locations
# We're specifying the full paths here for security reasons - you'll need to edit these if you have them installed to a different directory
# (an easy way to find where you have them installed is via the `which` command - ex. `which awk`)
AWK="/usr/bin/awk"
CP="/usr/bin/cp"
CURL="/usr/bin/curl"
CUT="/usr/bin/cut"
ECHO="/usr/bin/echo"
GREP="/usr/bin/grep"
HEAD="/usr/bin/head"
RM="/usr/bin/rm"
SHA512SUM="/usr/bin/sha512sum"
TAR="/usr/bin/tar"

# Set variables
THUNDERBIRD_ARCHITECTURE="x86_64"
THUNDERBIRD_URL_ARCHITECTURE="linux64"
THUNDERBIRD_LOCALE="en-US"
THUNDERBIRD_DIR="/opt/thunderbird"
THUNDERBIRD_URL="https://download.mozilla.org/?product=thunderbird-latest-ssl&os=$THUNDERBIRD_URL_ARCHITECTURE&lang=$THUNDERBIRD_LOCALE"
BASE_URL="https://ftp.mozilla.org/pub/thunderbird/releases"
CHECKSUMS_BASE_URL="https://productdelivery.mozilla-backup.org/pub/thunderbird/releases"
CHECKSUMS_URL="SHA512SUMS"
LATEST_VERSION=$("$CURL" --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https -s "$THUNDERBIRD_URL" | "$GREP" -oP 'https://download-installer\.cdn\.mozilla\.net/pub/thunderbird/releases/\K[0-9]+\.[0-9]+(\.[0-9]+)?')

# Check if the latest version is available
if [ -f "$THUNDERBIRD_DIR/application.ini" ]; then
    INSTALLED_VERSION=$("$GREP" 'Version=' "$THUNDERBIRD_DIR/application.ini" | "$CUT" -d'=' -f2 | "$HEAD" -n 1)
else
    "$ECHO" "Thunderbird is not installed in $THUNDERBIRD_DIR."
    exit 1
fi

if [ "$LATEST_VERSION" == "$INSTALLED_VERSION" ]; then
    "$ECHO" "Thunderbird is up to date (version $INSTALLED_VERSION)."
    exit 0
fi

"$ECHO" "Updating Thunderbird from version $INSTALLED_VERSION to $LATEST_VERSION..."

# Download the SHA512 checksums
CHECKSUMS_FILE="$CHECKSUMS_BASE_URL/$LATEST_VERSION/$CHECKSUMS_URL"
"$CURL" --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --tlsv1.3 --cert-status -O "$CHECKSUMS_FILE"

# Download the latest Thunderbird release
THUNDERBIRD_TAR="thunderbird-$LATEST_VERSION.tar.xz"
THUNDERBIRD_DOWNLOAD_URL="$BASE_URL/$LATEST_VERSION/linux-$THUNDERBIRD_ARCHITECTURE/$THUNDERBIRD_LOCALE/$THUNDERBIRD_TAR"
"$CURL" --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --tlsv1.3 -O "$THUNDERBIRD_DOWNLOAD_URL"

# Verify the checksum for the specific file
CHECKSUM=$("$GREP" "linux-$THUNDERBIRD_ARCHITECTURE/$THUNDERBIRD_LOCALE/$THUNDERBIRD_TAR" "$CHECKSUMS_URL" | "$AWK" '{print $1}')
DOWNLOADED_CHECKSUM=$("$SHA512SUM" "$THUNDERBIRD_TAR" | "$AWK" '{print $1}')

if [ "$CHECKSUM" != "$DOWNLOADED_CHECKSUM" ]; then
    "$ECHO" "Checksum verification failed. Aborting update."
    "$RM" "$THUNDERBIRD_TAR" "$THUNDERBIRD_URL"
    exit 1
fi

# Extract and update Thunderbird
"$TAR" -xf "$THUNDERBIRD_TAR"
"$CP" -v -R thunderbird/* "$THUNDERBIRD_DIR/"
"$RM" -rf thunderbird "$THUNDERBIRD_TAR" "$CHECKSUMS_URL"

"$ECHO" "Thunderbird has been updated to version $LATEST_VERSION."
