#!/bin/bash

# Set variables
THUNDERBIRD_DIR="/opt/thunderbird"
THUNDERBIRD_URL="https://download.mozilla.org/?product=thunderbird-latest-ssl&os=linux64&lang=en-US"
BASE_URL="https://ftp.mozilla.org/pub/thunderbird/releases"
CHECKSUMS_BASE_URL="https://productdelivery.mozilla-backup.org/pub/thunderbird/releases"
CHECKSUMS_URL="SHA512SUMS"
LATEST_VERSION=$(/usr/bin/curl -s "$THUNDERBIRD_URL" | /usr/bin/grep -oP 'https://download-installer\.cdn\.mozilla\.net/pub/thunderbird/releases/\K[0-9]+\.[0-9]+(\.[0-9]+)?')

# Check if the latest version is available
if [ -f "$THUNDERBIRD_DIR/application.ini" ]; then
    INSTALLED_VERSION=$(/usr/bin/grep 'Version=' "$THUNDERBIRD_DIR/application.ini" | /usr/bin/cut -d'=' -f2 | /usr/bin/head -n 1)
else
    /usr/bin/echo "Thunderbird is not installed in $THUNDERBIRD_DIR."
    exit 1
fi

if [ "$LATEST_VERSION" == "$INSTALLED_VERSION" ]; then
    /usr/bin/echo "Thunderbird is up to date (version $INSTALLED_VERSION)."
    exit 0
fi

/usr/bin/echo "Updating Thunderbird from version $INSTALLED_VERSION to $LATEST_VERSION..."

# Download the SHA512 checksums
CHECKSUMS_FILE="$CHECKSUMS_BASE_URL/$LATEST_VERSION/$CHECKSUMS_URL"
/usr/bin/curl -O "$CHECKSUMS_FILE"

# Download the latest Thunderbird release
THUNDERBIRD_TAR="thunderbird-$LATEST_VERSION.tar.xz"
THUNDERBIRD_DOWNLOAD_URL="$BASE_URL/$LATEST_VERSION/linux-x86_64/en-US/$THUNDERBIRD_TAR"
/usr/bin/curl -O "$THUNDERBIRD_DOWNLOAD_URL"

# Verify the checksum for the specific file
CHECKSUM=$(/usr/bin/grep "linux-x86_64/en-US/$THUNDERBIRD_TAR" "$CHECKSUMS_URL" | /usr/bin/awk '{print $1}')
DOWNLOADED_CHECKSUM=$(/usr/local/sbin/sha512sum "$THUNDERBIRD_TAR" | /usr/bin/awk '{print $1}')

if [ "$CHECKSUM" != "$DOWNLOADED_CHECKSUM" ]; then
    /usr/bin/echo "Checksum verification failed. Aborting update."
    /usr/bin/rm "$THUNDERBIRD_TAR" "$THUNDERBIRD_URL"
    exit 1
fi

# Extract and update Thunderbird
/usr/bin/tar -xf "$THUNDERBIRD_TAR"
/usr/bin/cp -v -R thunderbird/* "$THUNDERBIRD_DIR/"
/usr/bin/rm -rf thunderbird "$THUNDERBIRD_TAR" "$CHECKSUMS_URL"

/usr/bin/echo "Thunderbird has been updated to version $LATEST_VERSION."
