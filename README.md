# Korora Downloader

Korora does not have lots of money backing it, we're a volunteer-based community with the core developers picking up incurred costs.

As a result, Korora relies on free download services such as SourceForge and some sponsorship from Digital Ocean.

Some users are reporting that downloading Korora is too slow.

This is a script which uses the wonderful aria2 program to download Korora from multiple mirrors at once, which should dramatically increase the download speed.

## Dependencies for using the script

This script only works on Linux and you need the aria2 program installed.

Arch:

```bash
sudo pacman -S aria2
```

Debian/Ubuntu:

```bash
sudo apt-get install aria2
```


Fedora/CentOS:

```bash
sudo dnf install aria2
```

Gentoo:

```bash
sudo emerge -av aria2
```

openSUSE

```bash
sudo zypper in aria2
```

## Using the script

All you need to do is run the script! By default it will download the 64bit GNOME desktop, however you can change this by passing options to script.

See help for details:

```bash
$ bash ./get_korora.sh --help

Usage: ./get_korora.sh --arch <arch> --desktop <desktop> --release <release> [options]

Example: ./get_korora.sh --arch x86_64 --desktop gnome --release 23 --output ~/Downloads

Recommended args:
--arch <arch>		Architecture to download, i.e.:
			i386|x86_64 (defaults to x86_64)
--desktop <desktop>	Which desktop to download, i.e:
			cinnamon|gnome|kde|mate|xfce (defaults to gnome)
--release <release>	Which release of Korora to download, e.g.:
			22|23 (defaults to 23)

Options:
--output <dir>		Which directory to save the image in, e.g.:
			/home/chris/Downloads/korora (defaults to current dir)
--prompt <boolean>	Whether to prompt for confirmation before download, e.g.:
			true|false (defaults to true)
--beta			Get the beta version
--help			Show this help message

Short Options:
-a <string>		Same as --arch <arch>
-b			Same as --beta
-d <desktop>		Same as --desktop <desktop>
-h			Same as --help
-o <dir>		Same as --output <dir>
-p			Same as --prompt <boolean>
-r <release>		Same as --release <release>
```

### Burning the image
The most reliable way to boot the image is writing it to a USB stick using dd command.

See https://kororaproject.org/support/documentation/creating-bootable-media
