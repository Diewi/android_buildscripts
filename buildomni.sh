#!/bin/sh

################################################################################
# BUILD SCRIPT
#
# Launch the script only
#
# ${1}: path containing the adroid tree.
# ${2}: device codename (e.g. sirius)
# ${3}: device identifier (e.g. d6503). Launch 'lunch' without parameters to see
#       a list of all identifiers.
################################################################################

export BASE_DIR=omnio

export USE_CCACHE=1
export CCACHE_DIR=/mnt/android/ccache
export OUT_DIR_COMMON_BASE=/mnt/android/output
export OUT_DEVICE="${OUT_DIR_COMMON_BASE}/${BASE_DIR}/target/product/${2}"
export USER=jenkins

cd "${1}"

source build/envsetup.sh

# Cleanup steps to trigger re-copying of files. The make system handles source
# file changes.
rm -rf ${OUT_DEVICE}/cache
rm -rf ${OUT_DEVICE}/data
rm -rf ${OUT_DEVICE}/recovery
rm -rf ${OUT_DEVICE}/root
rm -rf ${OUT_DEVICE}/system
rm -rf ${OUT_DEVICE}/*.zip
rm -rf "${OUT_DIR_COMMON_BASE}/${BASE_DIR}"/dist/*

export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4g"
export ANDROID_JACK_VM_ARGS="$JACK_SERVER_VM_ARGUMENTS"
#./prebuilts/sdk/tools/jack-admin kill-server || true
#./prebuilts/sdk/tools/jack-admin uninstall-server
#./prebuilts/sdk/tools/jack-admin start-server || true

# Configure the env for the device
if [ "$#" -eq 4 ]; then
	echo "!!!! Using lunch !!!!"
	echo "User: " ${USER}
	export ROM_BUILDTYPE=${4}
#	breakfast ${2}
#	mka cookies
	brunch ${2}
	#make -j3 otapackage
else
	echo " !!!! Using breakfast !!!! "
	breakfast omni_${2}${3}
	make -j3 ${5}
fi

# Run the build to produce an installable update zip file
#make -j3 ${1}

