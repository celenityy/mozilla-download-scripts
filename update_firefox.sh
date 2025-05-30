#!/bin/bash

# Set variables
FIREFOX_DIR="/opt/firefox"
FIREFOX_URL="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
BASE_URL="https://ftp.mozilla.org/pub/firefox/releases"
CHECKSUMS_BASE_URL="https://productdelivery.mozilla-backup.org/pub/firefox/releases"
CHECKSUMS_URL="SHA512SUMS"
LATEST_VERSION=$(/usr/bin/curl --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https -s "$FIREFOX_URL" | /usr/bin/grep -oP 'https://download-installer\.cdn\.mozilla\.net/pub/firefox/releases/\K[0-9]+\.[0-9]+(\.[0-9]+)?')

# Check if the latest version is available
if [ -f "$FIREFOX_DIR/application.ini" ]; then
    INSTALLED_VERSION=$(/usr/bin/grep 'Version=' "$FIREFOX_DIR/application.ini" | /usr/bin/cut -d'=' -f2 | /usr/bin/head -n 1)
else
    /usr/bin/echo "Firefox is not installed in $FIREFOX_DIR."
    exit 1
fi

if [ "$LATEST_VERSION" == "$INSTALLED_VERSION" ]; then
    /usr/bin/echo "Firefox is up to date (version $INSTALLED_VERSION)."
    exit 0
fi

/usr/bin/echo "Updating Firefox from version $INSTALLED_VERSION to $LATEST_VERSION..."

# Download the SHA512 checksums
CHECKSUMS_FILE="$CHECKSUMS_BASE_URL/$LATEST_VERSION/$CHECKSUMS_URL"
/usr/bin/curl --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --tlsv1.3 --cert-status -O "$CHECKSUMS_FILE"

# Download the latest Firefox release
FIREFOX_TAR="firefox-$LATEST_VERSION.tar.xz"
FIREFOX_DOWNLOAD_URL="$BASE_URL/$LATEST_VERSION/linux-x86_64/en-US/$FIREFOX_TAR"
/usr/bin/curl --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --tlsv1.3 -O "$FIREFOX_DOWNLOAD_URL"

# Verify the checksum for the specific file
CHECKSUM=$(/usr/bin/grep "linux-x86_64/en-US/$FIREFOX_TAR" "$CHECKSUMS_URL" | /usr/bin/awk '{print $1}')
DOWNLOADED_CHECKSUM=$(/usr/local/sbin/sha512sum "$FIREFOX_TAR" | /usr/bin/awk '{print $1}')

if [ "$CHECKSUM" != "$DOWNLOADED_CHECKSUM" ]; then
    /usr/bin/echo "Checksum verification failed. Aborting update."
    /usr/bin/rm "$FIREFOX_TAR" "$CHECKSUMS_URL"
    exit 1
fi

# Extract and update Firefox
/usr/bin/tar -xf "$FIREFOX_TAR"
/usr/bin/cp -v -R firefox/* "$FIREFOX_DIR/"
/usr/bin/rm -rf firefox "$FIREFOX_TAR" "$CHECKSUMS_URL"

/usr/bin/echo "Firefox has been updated to version $LATEST_VERSION."
