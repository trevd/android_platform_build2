function initialize_ccache(){
	export USE_CCACHE=1
	mkdir -p $PWD/.ccache
	export CCACHE_DIR=$PWD/.ccache
	prebuilts/misc/linux-x86/ccache/ccache -M 50G
}
echo "Running build2"
unset ANDROID_BUILD_PATHS
source build/envsetup.sh
echo $ANDROID_BUILD_PATHS
alias mmwin='USE_MINGW=true mm'
alias mmmac='USE_DARWIN=true mm'
alias mmpi='USE_PI=true mm'
initialize_ccache

#export MAC_SDKROOT=$(dirname `which i686-apple-darwin10-gcc`)
export MAC_SDK_VERSION="10.6"
