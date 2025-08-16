# Mozilla Download Scripts

This repo contains bash scripts for downloading, installing, automatically updating, and uninstalling Mozilla software *(Currently includes **Firefox** and **Thunderbird**)* for GNU/Linux distributions.

## Features

- Archives are downloaded directly from Mozilla, providing users with immediate updates *(No need to wait/rely on distro packagers)*, and the most authentic Firefox experience possible *(No distro tweaks/customizations)*.
- Checks for updates on **boot** and **hourly**, to ensure users are up to date as quick as possible.
- Verifies the SHA-512 checksum of downloaded archives to preserve integrity - **Installations will fail if they don't match**.

## Motivation

- Distribution-packaged versions of Firefox typically receive delayed updates, which can leave users vulnerable to security issues.
- Distributions also typically customize/make changes to Firefox and Thunderbird - sometimes at the direct cost of privacy and security. For instance, Fedora/Red Hat [allow **all** `https` websites to use SPNEGO/Negotiate Authentication](https://src.fedoraproject.org/rpms/firefox/blob/rawhide/f/firefox-redhat-default-prefs.js#_25), [disable DNS over HTTPS](https://src.fedoraproject.org/rpms/firefox/blob/rawhide/f/firefox-redhat-default-prefs.js#_28), [add a custom external/remote homepage](https://src.fedoraproject.org/rpms/firefox/blob/rawhide/f/firefox-redhat-default-prefs.js#_17), [enable GNOME integration](https://src.fedoraproject.org/rpms/firefox/blob/rawhide/f/firefox-redhat-default-prefs.js#_31), and [allow add-ons to be sideloaded/enabled without user consent](https://src.fedoraproject.org/rpms/firefox/blob/rawhide/f/firefox-enable-addons.patch) by default.
- When using distribution-packaged versions of Firefox, you're not only trusting Mozilla - but you're also adding additional trust to the package maintainer(s), and by extension increasing your attack surface.
- Firefox and Thunderbird's built-in updater [is currently broken](https://bugzilla.mozilla.org/show_bug.cgi?id=1940481) if the user doesn't have write access to the installation directory - which isn't really preferable from a security perspective.
- At least for Fedora, the only packaged version of Thunderbird is ESR - so this allows users to use the **`release`** variant.

## Notes

- **Firefox** users of **Debian-based** distributions should prefer to use [Mozilla's official `apt` repository](https://support.mozilla.org/kb/install-firefox-linux#w_install-firefox-deb-package-for-debian-based-distributions-recommended), instead of these scripts.
- These scripts are designed for and tested on **Fedora**, but they should also work on other distributions - see below for more details on changes you might need to make.
- Only **glibc** builds are supported.

## Preparation

- You should first ensure that **`cronie`**, **`curl`** and **`tar`** are installed on your system.

After downloading your script(s) *(see below)*, you may need to make a few changes to adapt them for your environment.

- It's assumed that Firefox is installed to `/opt/firefox`. You can change this if needed by editing the value of the `FIREFOX_DIR` variable.
- It's assumed that Thunderbird is installed to `/opt/thunderbird`. You can change this if needed by editing the value of the `THUNDERBIRD_DIR` variable.
- It's assumed that your preferred locale is `en-US`. You can change this if needed by editing the value of the `FIREFOX_LOCALE` and/or `THUNDERBIRD_LOCALE` variables.
- It's assumed that you're using the `x86_64` architecture. If you're using a `32-bit` system, you should change the value of `FIREFOX_ARCHITECTURE`/`THUNDERBIRD_ARCHITECTURE` to `i686` **and** the value of `FIREFOX_URL_ARCHITECTURE`/`THUNDERBIRD_URL_ARCHITECTURE` to `linux`. **For Firefox**: If you're using `ARM64`, you should change the value of `FIREFOX_ARCHITECTURE` to `aarch64` **and** the value of `FIREFOX_URL_ARCHITECTURE` to `linux64-aarch64`.

For security reasons, full paths are specified for executables, *(using variables that correspond to each executable)*. These locations should be the same across most distributions, but depending on your set-up, you might need to change them. An easy way to check where an executable is located is with the `which` command *(Ex: `which curl`)*. If the output of the `which` command for the corresponding tool doesn't match the value of the variable in your script(s) of choice *(ex. the `CURL` variable for `curl`)*, you'll need to edit the value of the variable corresponding to the executable that doesn't match.

So, for example, by default, we set the `AWK` variable to `/usr/bin/awk`. If I ran `which awk`, and my output was `/usr/local/bin/awk`, I would change the value of the `AWK` variable to `/usr/local/bin/awk` in my downloaded script(s).

## Set-up

### Installation

You'll first want to uninstall Firefox and/or Thunderbird from your package manager if already installed, and you'll want to install Firefox and/or Thunderbird from Mozilla. You can do this manually *(See [here](https://support.mozilla.org/kb/install-firefox-linux) for Firefox, and [here](https://support.mozilla.org/kb/installing-thunderbird-linux) for Thunderbird))*, or with the installation script:

#### sudo

*(If you run `which sudo` and your output is different than `/usr/bin/sudo`, replace `/usr/bin/sudo` with your output/actual location. The same applies for `chmod`, `curl`, and any other commands below)*.

**Firefox**:

```sh
/usr/bin/curl --cert-status --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error -O -sSL https://gitlab.com/celenityy/mozilla-download-scripts/-/raw/pages/install_firefox.sh
/usr/bin/sudo /usr/bin/chmod -v 744 install_firefox.sh
/usr/bin/sudo ./install_firefox.sh
/usr/bin/rm -f install_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/curl --cert-status --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error -O -sSL https://gitlab.com/celenityy/mozilla-download-scripts/-/raw/pages/install_thunderbird.sh
/usr/bin/sudo /usr/bin/chmod -v 744 install_thunderbird.sh
/usr/bin/sudo ./install_thunderbird.sh
/usr/bin/rm -f install_thunderbird.sh
```

#### run0 (ex. secureblue)

**Firefox**:

```sh
/usr/bin/curl --cert-status --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error -O -sSL https://gitlab.com/celenityy/mozilla-download-scripts/-/raw/pages/install_firefox.sh
/usr/bin/run0 /usr/bin/chmod -v 744 install_firefox.sh
/usr/bin/run0 ./install_firefox.sh
/usr/bin/rm -f install_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/curl --cert-status --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error -O -sSL https://gitlab.com/celenityy/mozilla-download-scripts/-/raw/pages/install_thunderbird.sh
/usr/bin/run0 /usr/bin/chmod -v 744 install_thunderbird.sh
/usr/bin/run0 ./install_thunderbird.sh
/usr/bin/rm -f install_thunderbird.sh
```

You're now ready to set-up automatic updates:

**1**. Download your script(s):

**Firefox**:

```sh
/usr/bin/curl --cert-status --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error -O -sSL https://gitlab.com/celenityy/mozilla-download-scripts/-/raw/pages/update_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/curl --cert-status --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error -O -sSL https://gitlab.com/celenityy/mozilla-download-scripts/-/raw/pages/update_thunderbird.sh
```

**2**. Make any necessary changes as described above.

**3**. Ensure the script(s) have proper permissions:

#### sudo

*(If you run `which sudo` and your output is different than `/usr/bin/sudo`, replace `/usr/bin/sudo` with your output/actual location. The same applies for `chmod` and any other commands below)*.

**Firefox**:

```sh
/usr/bin/sudo /usr/bin/chmod -v 744 update_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/sudo /usr/bin/chmod -v 744 update_thunderbird.sh
```

#### run0 (ex. secureblue)

**Firefox**:

```sh
/usr/bin/run0 /usr/bin/chmod -v 744 update_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/run0 /usr/bin/chmod -v 744 update_thunderbird.sh
```

**4**. Copy the script(s) to your preferred location(s). I personally use `/opt/celenity/Scripts/`:

#### sudo

**Firefox**:

```sh
/usr/bin/sudo /usr/bin/mkdir -v -p /opt/celenity/Scripts
/usr/bin/sudo /usr/bin/cp update_firefox.sh /opt/celenity/Scripts/update_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/sudo /usr/bin/mkdir -v -p /opt/celenity/Scripts
/usr/bin/sudo /usr/bin/cp update_thunderbird.sh /opt/celenity/Scripts/update_thunderbird.sh
```

#### run0 (ex. secureblue)

**Firefox**:

```sh
/usr/bin/run0 /usr/bin/mkdir -v -p /opt/celenity/Scripts
/usr/bin/run0 /usr/bin/cp update_firefox.sh /opt/celenity/Scripts/update_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/run0 /usr/bin/mkdir -v -p /opt/celenity/Scripts
/usr/bin/run0 /usr/bin/cp update_thunderbird.sh /opt/celenity/Scripts/update_thunderbird.sh
```

**5**. Update your `crontab`:

*(You can replace the value of `EDITOR` below with whatever you prefer, this is using `nano`, installed at `/usr/bin/nano`)*.

#### sudo

```sh
/usr/bin/sudo EDITOR=/usr/bin/nano /usr/bin/crontab -e
```

#### run0 (ex. secureblue)

```sh
/usr/bin/run0 EDITOR=/usr/bin/nano /usr/bin/crontab -e
```

with the following:

**Firefox**:

```sh
@reboot /opt/celenity/Scripts/update_firefox.sh
0 * * * * /opt/celenity/Scripts/update_firefox.sh
```

**Thunderbird**:

```sh
@reboot /opt/celenity/Scripts/update_thunderbird.sh
0 * * * * /opt/celenity/Scripts/update_thunderbird.sh
```

Save, and enjoy. :)

You can manually give it a test/run the script with the following command(s):

#### sudo

**Firefox**:

```sh
/usr/bin/sudo /opt/celenity/Scripts/update_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/sudo /opt/celenity/Scripts/update_thunderbird.sh
```

#### run0 (ex. secureblue)

**Firefox**:

```sh
/usr/bin/run0 /opt/celenity/Scripts/update_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/run0 /opt/celenity/Scripts/update_thunderbird.sh
```

## Uninstall

You can uninstall Firefox and/or Thunderbird with the corresponding uninstall script(s):

#### sudo

*(If you run `which sudo` and your output is different than `/usr/bin/sudo`, replace `/usr/bin/sudo` with your output/actual location. The same applies for `chmod`, `curl`, and any other commands below)*.

**Firefox**:

```sh
/usr/bin/curl --cert-status --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error -O -sSL https://gitlab.com/celenityy/mozilla-download-scripts/-/raw/pages/uninstall_firefox.sh
/usr/bin/sudo /usr/bin/chmod -v 744 uninstall_firefox.sh
/usr/bin/sudo ./uninstall_firefox.sh
/usr/bin/rm -f uninstall_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/curl --cert-status --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error -O -sSL https://gitlab.com/celenityy/mozilla-download-scripts/-/raw/pages/uninstall_thunderbird.sh
/usr/bin/sudo /usr/bin/chmod -v 744 uninstall_thunderbird.sh
/usr/bin/sudo ./uninstall_thunderbird.sh
/usr/bin/rm -f uninstall_thunderbird.sh
```

#### run0 (ex. secureblue)

**Firefox**:

```sh
/usr/bin/curl --cert-status --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error -O -sSL https://gitlab.com/celenityy/mozilla-download-scripts/-/raw/pages/uninstall_firefox.sh
/usr/bin/run0 /usr/bin/chmod -v 744 uninstall_firefox.sh
/usr/bin/run0 ./uninstall_firefox.sh
/usr/bin/rm -f uninstall_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/curl --cert-status --doh-cert-status --no-insecure --no-proxy-insecure --no-sessionid --no-ssl --no-ssl-allow-beast --no-ssl-auto-client-cert --no-ssl-no-revoke --no-ssl-revoke-best-effort --proto -all,https --proto-default https --proto-redir -all,https --show-error -O -sSL https://gitlab.com/celenityy/mozilla-download-scripts/-/raw/pages/uninstall_thunderbird.sh
/usr/bin/run0 /usr/bin/chmod -v 744 uninstall_thunderbird.sh
/usr/bin/run0 ./uninstall_thunderbird.sh
/usr/bin/rm -f uninstall_thunderbird.sh
```
