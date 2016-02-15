#!/bin/bash
#
# Script to download Korora with aria2 using multiple mirrors
# which should speed up download
#

#set -x

# Make sure we are not running this as root
[[ "${EUID}" == 0 ]] && { echo "Please don't run this script as root." ; exit 1 ; }

# Check that the aria2 binary is available
command -v aria2c >/dev/null || { echo "Please install aria2 and re-run this script." ; exit 1 ; }

# Variables
ARCH=${ARCH:-x86_64} # default to x86_64
BETA=""
DESKTOP=${DESKTOP:-gnome} # default to GNOME
LIVE=""
OUTPUT="${PWD}"
PROMPT="true"
RELEASE=${RELEASE:-23} # default to 23
MIRRORS=(
	citylan
	colocrossing
	freefr
	heanet
	ignum
	internode
	iweb
	jaist
	kaz
	kent
	liquidtelecom
	nbtelecom
	nchc
	netassist
	netcologne
	netix
	superb-dca2
	superb-dca3
	tcpdiag
	tenet
	ufpr
	vorboss
)
declare -A SHA1=(
	["22-i386-cinnamon"]="7a2be34ae8d47069ff4735331d8c2adc62a5bb6b"
	["22-i386-gnome"]="d0d3588aeee249f151c94c927b5ba29946c85bfd"
	["22-i386-kde"]="1eeba35c2636cdeb17d6c2bbcadc63318bcc66d5"
	["22-i386-mate"]="96e45533a2601bded6b5e8226ae410e90323920d"
	["22-i386-xfce"]="121602fc333834aac8659ca20763a37209997e6d"
	["22-x86_64-cinnamon"]="bc5ac60cfb1d769673c9622b226cd9f6b6ed636f"
	["22-x86_64-gnome"]="e3425458c02790d4cc564277a9a34d5b1427d249"
	["22-x86_64-kde"]="c78184f0893aca8c64df29a3a9152735c5d745c2"
	["22-x86_64-mate"]="086be38a1c03590a1ab3fbe0f7ecaae5b2eeef98"
	["22-x86_64-xfce"]="7b48b362c929ca086d1540f0d8dcd427370a8290"
	["23-i386-cinnamon"]="16a9acdcf71aaccda5a5665d9e9cede7ebcc140d"
	["23-i386-gnome"]="e3430c65182dd18e8166696684cade6b93d1a78e"
	["23-i386-kde"]="b9d50dca536fdc581ac9070a899e189e2a01bb0b"
	["23-i386-mate"]="4ca35cedaba7a18ac92c97fc55cc8b56b5db817e"
	["23-i386-xfce"]="7fca915356b7b50b6a09d8f8178abfc8189cd74e"
	["23-x86_64-cinnamon"]="b1e7bfb0c4c4867fa805bae26f072bdd83acea31"
	["23-x86_64-gnome"]="6c4fe80df9e869167d9bf68a173fbbc481e637b2"
	["23-x86_64-kde"]="43b6a6c8076bca3d55af67b23eae59ad8152abd0"
	["23-x86_64-mate"]="83a5949ccef5ea1efea464064f33d358cbf674fe"
	["23-x86_64-xfce"]="df4abd79c2a3a6f01583d24d57f1c5b418e023a2"
)

# Function to print usage and exit
usage() {
	cat << EOF
Usage: $0 --arch <arch> --desktop <desktop> --release <release> [options]

Example: $0 --arch x86_64 --desktop gnome --release 23 --output ~/Downloads

Recommended args:
--arch <arch>		Architecture to download, i.e.:
			  i386|x86_64 (defaults to x86_64)
--desktop <desktop>	Which desktop to download, i.e:
			  cinnamon|gnome|kde|mate|xfce (defaults to gnome)
--release <release>	Which release of Korora to download, e.g.:
			  22|23 (defaults to 23)

Options:
--output <dir>		Which directory to save the image in, e.g.:
			  ${HOME}/Downloads/korora (defaults to current dir)
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

EOF
	exit 1
}

# Parse command line arguments
CMD_LINE=$(getopt -o a:bd:ho:p:r: --longoptions arch:,beta,desktop:,help,output:,prompt:,release: -n "$0" -- "$@")
eval set -- "${CMD_LINE}"

while true ; do
	case "${1}" in
	-a|--arch)
		ARCH="${2,,}"
		shift 2
		;;
	-b|--beta)
		BETA="-beta"
		shift
		;;
	-d|--desktop)
		DESKTOP="${2,,}"
		shift 2
		;;
	-h|--help)
		usage
		;;
	-o|--output)
		OUTPUT="${2}"
		shift 2
		;;
	-p|--prompt)
		PROMPT="${2,,}"
		shift 2
		;;
	-r|--release)
		RELEASE="${2}"
		shift 2
		;;
	--)
		shift
		break
		;;
	*)
		usage
		;;
	esac
done

# Check that we have a legitimate release
[[ "${SHA1["${RELEASE}${BETA}-${ARCH}-${DESKTOP}"]}" ]] || { echo "korora-${RELEASE}${BETA}-${ARCH}-${DESKTOP} doesn't seem to be a valid release, sorry." ; exit 1 ; }

# Confirm prompt
if [[ "${PROMPT}" == "true" ]]; then
	echo "Will download korora-${RELEASE}${BETA}-${ARCH}-${DESKTOP}"
	read -p "Do you want to continue? [y/n]: " answer
	if [[ ! "${answer,,}" =~ y ]]; then
		echo "OK, exiting"
		exit 0
	fi
fi

# Fix 22 download image names
[[ "${RELEASE}" == 22 ]] && LIVE="-live"

# Create output location
mkdir -p "${OUTPUT}" 2>/dev/null || { echo "Could not create output directory, sorry." ; exit 1 ; }

# Do the download
aria2c --checksum=sha-1=${SHA1["${RELEASE}${BETA}-${ARCH}-${DESKTOP}"]} --console-log-level notice --dir "${OUTPUT}" --continue=true --max-connection-per-server=1 --split=${#MIRRORS[@]} $(for x in ${MIRRORS[@]} ; do echo -n "http://${x}.dl.sourceforge.net/project/kororaproject/${RELEASE}/korora-${RELEASE}${BETA}-${ARCH}-${DESKTOP}${LIVE}.iso " ; done)

# Print status of download
if [[ "$?" != 0 ]]; then
	echo -e "\nIt seems we had a problem downloading the image, sorry."
	exit 1
else
	echo -e "\nKorora image successfully downloaded."
fi
