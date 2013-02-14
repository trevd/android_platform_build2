
function initialize_ccache(){
	export USE_CCACHE=1
	mkdir $PWD/.ccache
	export CCACHE_DIR=$PWD/.ccache
	prebuilts/misc/linux-x86/ccache/ccache -M 50G
}
echo "Running build2"
unset ANDROID_BUILD_PATHS
source build/envsetup.sh
echo $ANDROID_BUILD_PATHS
alias mmwin='USE_MINGW=true mm'
initialize_ccache
