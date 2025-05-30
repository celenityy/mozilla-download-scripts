# Mozilla Download Scripts

This repo contains scripts for downloading and automatically updating Mozilla software *(Currently includes **Firefox** and **Thunderbird**)* for GNU/Linux distributions.

## Features

- Archives are downloaded directly from Mozilla, providing users with immediate updates *(No need to wait/rely on distro packagers)*, and the most authentic Firefox experience possible *(No distro tweaks/customizations)*.
- Checks for updates on **boot** and **hourly**, to ensure users are up to date as quick as possible.
- Verifies the SHA-512 checksum of downloaded archives to preserve integrity - **Updates will fail if they don't match**.

## Motivation

- Distribution-packaged versions of Firefox typically receive delayed updates, which can leave users vulnerable to security issues.
- Distributions also typically customize/make changes to Firefox and Thunderbird - sometimes at the direct cost of privacy and security. For instance, Fedora/Red Hat [allow **all** `https` websites to use SPNEGO/Negotiate Authentication](https://src.fedoraproject.org/rpms/firefox/blob/rawhide/f/firefox-redhat-default-prefs.js#_25), [disable DNS over HTTPS](https://src.fedoraproject.org/rpms/firefox/blob/rawhide/f/firefox-redhat-default-prefs.js#_28), [add a custom external/remote homepage](https://src.fedoraproject.org/rpms/firefox/blob/rawhide/f/firefox-redhat-default-prefs.js#_17), [enable GNOME integration](https://src.fedoraproject.org/rpms/firefox/blob/rawhide/f/firefox-redhat-default-prefs.js#_31), and [allow add-ons to be sideloaded/enabled without user consent](https://src.fedoraproject.org/rpms/firefox/blob/rawhide/f/firefox-enable-addons.patch) by default.
- When using distribution-packaged versions of Firefox, you're not only trusting Mozilla - but you're also adding additional trust to the package maintainer(s), and by extension increasing your attack surface.
- Firefox and Thunderbird's built-in updater [is currently broken](https://bugzilla.mozilla.org/show_bug.cgi?id=1940481) if the user doesn't have write access to the installation directory - which isn't really preferable from a security perspective.
- At least for Fedora, the only packaged version of Thunderbird is ESR - so this allows users to use the **`release`** variant.

## Notes

- **Firefox** users of **Debian-based** distributions should prefer to use [Mozilla's official `apt` repository](https://support.mozilla.org/kb/install-firefox-linux#w_install-firefox-deb-package-for-debian-based-distributions-recommended), instead of these scripts.
- These scripts are designed for and tested on **Fedora**, but they should also work on other distributions - see below for more details on changes you might need to make.

## Preparation

- You should first ensure that **`cronie`**, **`curl`** and **`tar`** are installed on your system.

After downloading your script(s) *(see below)*, you may need to make a few changes to adapt them for your environment.

- It's assumed that Firefox is installed to `/opt/firefox`. You can change this if needed by editing the value of `FIREFOX_DIR`.
- It's assumed that Thunderbird is installed to `/opt/thunderbird`. You can change this if needed by editing the value of `THUNDERBIRD_DIR`.
- It's assumed that your preferred locale is `en-US`. You can change this if needed by replacing the value of `en_US` with your locale of choice.

For security reasons, full paths are specified for executables. This is using their locations on **Fedora**, but depending on your distro, they may or may not be located in the same place - so if you're not using Fedora, you should confirm, and change the paths if necessary. An easy way to check is with the `which` command *(Ex: `which curl`)*. If the output of the `which` command for the corresponding tool doesn't match below, you'll need to modify the script and replace the location below with the location on your system:

- It's assumed that `awk` is located at `/usr/bin/awk`.
- It's assumed that `cp` is located at `/usr/bin/cp`.
- It's assumed that `curl` is located at `/usr/bin/curl`.
- It's assumed that `cut` is located at `/usr/bin/cut`.
- It's assumed that `echo` is located at `/usr/bin/echo`.
- It's assumed that `grep` is located at `/usr/bin/grep`.
- It's assumed that `head` is located at `/usr/bin/head`.
- It's assumed that `rm` is located at `/usr/bin/rm`.
- It's assumed that `sha512sum` is located at `/usr/local/sbin/sha512sum`.
- It's assumed that `tar` is located at `/usr/bin/tar`.

So, for example, if I ran `which awk` and my output was `/usr/local/bin/awk`, I would replace instances of `/usr/bin/awk` with `/usr/local/bin/awk` in my downloaded script(s).

## Set-up

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

*(If you run `which sudo` and your output is different than `/usr/bin/sudo`, replace `/usr/bin/sudo` with your output/actual location. The same applies for `chmod` and any other commands below)*.

**Firefox**:

```sh
/usr/bin/sudo /usr/bin/chmod -v 744 update_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/sudo /usr/bin/chmod -v 744 update_thunderbird.sh
```

**4**. Copy the script(s) to your preferred location(s). I personally use `/opt/celenity/Scripts/`:

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

**5**. Update your `crontab`:

*(You can replace the value of `EDITOR` below with whatever you prefer, this is using `nano`, installed at `/usr/bin/nano`)*.

```sh
/usr/bin/sudo EDITOR=/usr/bin/nano /usr/bin/crontab -e
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

**Firefox**:

```sh
/usr/bin/sudo /opt/celenity/Scripts/update_firefox.sh
```

**Thunderbird**:

```sh
/usr/bin/sudo /opt/celenity/Scripts/update_thunderbird.sh
```
