find_repo_root()
# desc: Find root of a repo tree and echo it
{
    (
        max_depth=10
        while ! [ -e "$PWD/.repo" ] ; do
            [ $max_depth -eq 0 ] && return 1
            cd ..
            max_depth=$((max_depth-1))
        done
        echo "$PWD"
    )
}

usage(){
    cat <<EOF
Build kernel for supported devices
Usage: ${0##*/} [-k -p <platform>]

Options:
-k              keep kernel tmp after build
-p <platform>   only build the kernel for <platform>
-O <directory>  build kernel in <directory>
EOF
}


arguments=khp:O:
while getopts $arguments argument ; do
    case $argument in
        k) keep_kernel_tmp=t ;;
        p) only_build_for=$OPTARG;;
        O) build_directory=$OPTARG;;
        h) usage; exit 0;;
        ?) usage; exit 1;;
    esac
done

if [ -z "$ANDROID_BUILD_TOP" ]; then
    ANDROID_ROOT=$(find_repo_root)
    ANDROID_ROOT=$(realpath "$ANDROID_ROOT")
    echo "ANDROID_BUILD_TOP not set, guessing root at $ANDROID_ROOT"
else
    ANDROID_ROOT="$ANDROID_BUILD_TOP"
fi

PLATFORMS="nagara yodo"

# Mkdtimg tool
MKDTIMG=$ANDROID_ROOT/out/host/linux-x86/bin/mkdtimg

KERNEL_TOP=$ANDROID_ROOT/kernel/sony/msm-5.15
# $KERNEL_TMP sub dir per script
c=${0##*-}
KERNEL_TMP=${build_directory:-$ANDROID_ROOT/out/kernel-5.15/${c%%.sh}}
