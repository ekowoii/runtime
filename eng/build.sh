#!/usr/bin/env bash

set -ue

source="${BASH_SOURCE[0]}"

# resolve $source until the file is no longer a symlink
while [[ -h "$source" ]]; do
  scriptroot="$( cd -P "$( dirname "$source" )" && pwd )"
  source="$(readlink "$source")"
  # if $source was a relative symlink, we need to resolve it relative to the path where the
  # symlink file was located
  [[ $source != /* ]] && source="$scriptroot/$source"
done
scriptroot="$( cd -P "$( dirname "$source" )" && pwd )"

usage()
{
  echo "Common settings:"
  echo "  --arch (-a)                     Target platform: x86, x64, arm, armv6, armel, arm64, loongarch64, riscv64, s390x, ppc64le or wasm."
  echo "                                  [Default: Your machine's architecture.]"
  echo "  --binaryLog (-bl)               Output binary log."
  echo "  --cross                         Optional argument to signify cross compilation."
  echo "  --configuration (-c)            Build configuration: Debug, Release or Checked."
  echo "                                  Checked is exclusive to the CLR subset. It is the same as Debug, except code is"
  echo "                                  compiled with optimizations enabled."
  echo "                                  [Default: Debug]"
  echo "  --help (-h)                     Print help and exit."
  echo "  --hostConfiguration (-hc)       Host build configuration: Debug, Release or Checked."
  echo "                                  [Default: Debug]"
  echo "  --librariesConfiguration (-lc)  Libraries build configuration: Debug or Release."
  echo "                                  [Default: Debug]"
  echo "  --os                            Target operating system: windows, linux, freebsd, osx, maccatalyst, tvos,"
  echo "                                  tvossimulator, ios, iossimulator, android, browser, wasi, netbsd, illumos, solaris"
  echo "                                  linux-musl, linux-bionic, tizen, or haiku."
  echo "                                  [Default: Your machine's OS.]"
  echo "  --targetrid <rid>               Optional argument that overrides the target rid name."
  echo "  --projects <value>              Project or solution file(s) to build."
  echo "  --runtimeConfiguration (-rc)    Runtime build configuration: Debug, Release or Checked."
  echo "                                  Checked is exclusive to the CLR runtime. It is the same as Debug, except code is"
  echo "                                  compiled with optimizations enabled."
  echo "                                  [Default: Debug]"
  echo "  -runtimeFlavor (-rf)            Runtime flavor: CoreCLR or Mono."
  echo "                                  [Default: CoreCLR]"
  echo "  --subset (-s)                   Build a subset, print available subsets with -subset help."
  echo "                                 '--subset' can be omitted if the subset is given as the first argument."
  echo "                                  [Default: Builds the entire repo.]"
  echo "  --usemonoruntime                Product a .NET runtime with Mono as the underlying runtime."
  echo "  --verbosity (-v)                MSBuild verbosity: q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic]."
  echo "                                  [Default: Minimal]"
  echo "  --use-bootstrap                 Use the results of building the bootstrap subset to build published tools on the target machine."
  echo "  --bootstrap                     Build the bootstrap subset and then build the repo with --use-bootstrap."
  echo ""

  echo "Actions (defaults to --restore --build):"
  echo "  --build (-b)               Build all source projects."
  echo "                             This assumes --restore has been run already."
  echo "  --clean                    Clean the solution."
  echo "  --pack                     Package build outputs into NuGet packages."
  echo "  --publish                  Publish artifacts (e.g. symbols)."
  echo "                             This assumes --build has been run already."
  echo "  --rebuild                  Rebuild all source projects."
  echo "  --restore (-r)             Restore dependencies."
  echo "  --sign                     Sign build outputs."
  echo "  --test (-t)                Incrementally builds and runs tests."
  echo "                             Use in conjunction with --testnobuild to only run tests."
  echo ""

  echo "Libraries settings:"
  echo "  --coverage                 Collect code coverage when testing."
  echo "  --framework (-f)           Build framework: net10.0 or net481."
  echo "                             [Default: net10.0]"
  echo "  --testnobuild              Skip building tests when invoking -test."
  echo "  --testscope                Test scope, allowed values: innerloop, outerloop, all."
  echo ""

  echo "Native build settings:"
  echo "  --clang                    Optional argument to build using clang in PATH (default)."
  echo "  --clangx                   Optional argument to build using clang version x (used for Clang 7 and newer)."
  echo "  --clangx.y                 Optional argument to build using clang version x.y (used for Clang 6 and older)."
  echo "  --cmakeargs                User-settable additional arguments passed to CMake."
  echo "  --gcc                      Optional argument to build using gcc in PATH (default)."
  echo "  --gccx.y                   Optional argument to build using gcc version x.y."
  echo "  --portablebuild            Optional argument: set to false to force a non-portable build."
  echo "  --keepnativesymbols        Optional argument: set to true to keep native symbols/debuginfo in generated binaries."
  echo "  --ninja                    Optional argument: set to true to use Ninja instead of Make to run the native build."
  echo "  --pgoinstrument            Optional argument: build PGO-instrumented runtime"
  echo "  --fsanitize                Optional argument: Specify native sanitizers to instrument the native build with. Supported values are: 'address'."
  echo ""

  echo "Command line arguments starting with '/p:' are passed through to MSBuild."
  echo "Arguments can also be passed in with a single hyphen."
  echo ""

  echo "Here are some quick examples. These assume you are on a Linux x64 machine:"
  echo ""
  echo "* Build CoreCLR for Linux x64 on Release configuration:"
  echo "./build.sh clr -c release"
  echo ""
  echo "* Build Debug libraries with a Release runtime for Linux x64."
  echo "./build.sh clr+libs -rc release"
  echo ""
  echo "* Build Release libraries and their tests with a Checked runtime for Linux x64, and run the tests."
  echo "./build.sh clr+libs+libs.tests -rc checked -lc release -test"
  echo ""
  echo "* Build CoreCLR for Linux x64 on Debug configuration using Clang 9."
  echo "./build.sh clr -clang9"
  echo ""
  echo "* Build CoreCLR for Linux x64 on Debug configuration using GCC 8.4."
  echo "./build.sh clr -gcc8.4"
  echo ""
  echo "* Build CoreCLR for Linux x64 using extra compiler flags (-fstack-clash-protection)."
  echo "EXTRA_CFLAGS=-fstack-clash-protection EXTRA_CXXFLAGS=-fstack-clash-protection ./build.sh clr"
  echo ""
  echo "* Cross-compile CoreCLR runtime for Linux ARM64 on Release configuration."
  echo "./build.sh clr.runtime -arch arm64 -c release -cross"
  echo ""
  echo "However, for this example, you need to already have ROOTFS_DIR set up."
  echo "Further information on this can be found here:"
  echo "https://github.com/dotnet/runtime/blob/main/docs/workflow/building/coreclr/cross-building.md"
  echo ""
  echo "* Build Mono runtime for Linux x64 on Release configuration."
  echo "./build.sh mono -c release"
  echo ""
  echo "* Build Release coreclr corelib, crossgen corelib and update Debug libraries testhost to run test on an updated corelib."
  echo "./build.sh clr.corelib+clr.nativecorelib+libs.pretest -rc release"
  echo ""
  echo "* Build Debug mono corelib and update Release libraries testhost to run test on an updated corelib."
  echo "./build.sh mono.corelib+libs.pretest -rc debug -c release"
  echo ""
  echo ""
  echo "For more general information, check out https://github.com/dotnet/runtime/blob/main/docs/workflow/README.md"
}

initDistroRid()
{
    source "$scriptroot"/common/native/init-distro-rid.sh

    local passedRootfsDir=""
    local targetOs="$1"
    local targetArch="$2"
    local isCrossBuild="$3"

    # Only pass ROOTFS_DIR if __DoCrossArchBuild is specified and the current platform is not an Apple platform (that doesn't use rootfs)
    if [[ $isCrossBuild == 1 && "$targetOs" != "osx" && "$targetOs" != "android" && "$targetOs" != "ios" && "$targetOs" != "iossimulator" && "$targetOs" != "tvos" && "$targetOs" != "tvossimulator" && "$targetOs" != "maccatalyst" ]]; then
        passedRootfsDir=${ROOTFS_DIR}
    fi
    initDistroRidGlobal "${targetOs}" "${targetArch}" "${passedRootfsDir}"
}

showSubsetHelp()
{
  "$scriptroot/common/build.sh" "-restore" "-build" "/p:Subset=help" "/clp:nosummary /tl:false"
}

arguments=()
cmakeargs=''
extraargs=()
crossBuild=0
portableBuild=1
bootstrap=0

source $scriptroot/common/native/init-os-and-arch.sh

hostArch=$arch

# Check if an action is passed in
declare -a actions=("b" "build" "r" "restore" "rebuild" "testnobuild" "sign" "publish" "clean")
actInt=($(comm -12 <(printf '%s\n' "${actions[@]/#/-}" | sort) <(printf '%s\n' "${@/#--/-}" | sort)))
firstArgumentChecked=0

while [[ $# > 0 ]]; do
  opt="$(echo "${1/#--/-}" | tr "[:upper:]" "[:lower:]")"

  if [[ $firstArgumentChecked -eq 0 && $opt =~ ^[a-zA-Z.+]+$ ]]; then
    if [[ "$opt" == "help" ]]; then
      showSubsetHelp
      exit 0
    fi

    arguments+=("/p:Subset=$1")
    shift 1
    continue
  fi

  firstArgumentChecked=1

  case "$opt" in
     -help|-h|-\?|/?)
      usage
      exit 0
      ;;

     -subset|-s)
      if [ -z ${2+x} ]; then
        showSubsetHelp
        exit 0
      else
        passedSubset="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
        if [[ "$passedSubset" == "help" ]]; then
          showSubsetHelp
          exit 0
        fi
        arguments+=("/p:Subset=$2")
        shift 2
      fi
      ;;

     -arch|-a)
      if [ -z ${2+x} ]; then
        echo "No architecture supplied. See help (--help) for supported architectures." 1>&2
        exit 1
      fi
      passedArch="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
      case "$passedArch" in
        x64|x86|arm|armv6|armel|arm64|loongarch64|riscv64|s390x|ppc64le|wasm)
          arch=$passedArch
          ;;
        *)
          echo "Unsupported target architecture '$2'."
          echo "The allowed values are x86, x64, arm, armv6, armel, arm64, loongarch64, riscv64, s390x, ppc64le and wasm."
          exit 1
          ;;
      esac
      shift 2
      ;;

     -configuration|-c)
      if [ -z ${2+x} ]; then
        echo "No configuration supplied. See help (--help) for supported configurations." 1>&2
        exit 1
      fi
      passedConfig="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
      case "$passedConfig" in
        debug|release|checked)
          val="$(tr '[:lower:]' '[:upper:]' <<< ${passedConfig:0:1})${passedConfig:1}"
          ;;
        *)
          echo "Unsupported target configuration '$2'."
          echo "The allowed values are Debug, Release, and Checked."
          exit 1
          ;;
      esac
      arguments+=("-configuration" "$val")
      shift 2
      ;;

     -framework|-f)
      if [ -z ${2+x} ]; then
        echo "No framework supplied. See help (--help) for supported frameworks." 1>&2
        exit 1
      fi
      val="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
      arguments+=("/p:BuildTargetFramework=$val")
      shift 2
      ;;

     -os)
      if [ -z ${2+x} ]; then
        echo "No target operating system supplied. See help (--help) for supported target operating systems." 1>&2
        exit 1
      fi
      passedOS="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
      case "$passedOS" in
        windows)
          os="windows" ;;
        linux)
          os="linux" ;;
        freebsd)
          os="freebsd" ;;
        osx)
          os="osx" ;;
        maccatalyst)
          os="maccatalyst" ;;
        tvos)
          os="tvos" ;;
        tvossimulator)
          os="tvossimulator" ;;
        ios)
          os="ios" ;;
        iossimulator)
          os="iossimulator" ;;
        android)
          os="android" ;;
        browser)
          os="browser" ;;
        wasi)
          os="wasi" ;;
        illumos)
          os="illumos" ;;
        solaris)
          os="solaris" ;;
        linux-bionic)
          os="linux"
          __PortableTargetOS=linux-bionic
          ;;
        linux-musl)
          os="linux"
          __PortableTargetOS=linux-musl
          ;;
        haiku)
          os="haiku" ;;
        *)
          echo "Unsupported target OS '$2'."
          echo "Try 'build.sh --help' for values supported by '--os'."
          exit 1
          ;;
      esac
      arguments+=("/p:TargetOS=$os")
      shift 2
      ;;

     -pack)
      arguments+=("--pack" "/p:BuildAllConfigurations=true")
      shift 1
      ;;

     -testscope)
      if [ -z ${2+x} ]; then
        echo "No test scope supplied. See help (--help) for supported test scope values." 1>&2
        exit 1
      fi
      arguments+=("/p:TestScope=$2")
      shift 2
      ;;

     -testnobuild)
      arguments+=("/p:TestNoBuild=true")
      shift 1
      ;;

     -coverage)
      arguments+=("/p:Coverage=true")
      shift 1
      ;;

     -runtimeconfiguration|-rc)
      if [ -z ${2+x} ]; then
        echo "No runtime configuration supplied. See help (--help) for supported runtime configurations." 1>&2
        exit 1
      fi
      passedRuntimeConf="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
      case "$passedRuntimeConf" in
        debug|release|checked)
          val="$(tr '[:lower:]' '[:upper:]' <<< ${passedRuntimeConf:0:1})${passedRuntimeConf:1}"
          ;;
        *)
          echo "Unsupported runtime configuration '$2'."
          echo "The allowed values are Debug, Release, and Checked."
          exit 1
          ;;
      esac
      arguments+=("/p:RuntimeConfiguration=$val")
      shift 2
      ;;

     -runtimeflavor|-rf)
      if [ -z ${2+x} ]; then
        echo "No runtime flavor supplied. See help (--help) for supported runtime flavors." 1>&2
        exit 1
      fi
      passedRuntimeFlav="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
      case "$passedRuntimeFlav" in
        coreclr|mono)
          val="$(tr '[:lower:]' '[:upper:]' <<< ${passedRuntimeFlav:0:1})${passedRuntimeFlav:1}"
          ;;
        *)
          echo "Unsupported runtime flavor '$2'."
          echo "The allowed values are CoreCLR and Mono."
          exit 1
          ;;
      esac
      arguments+=("/p:RuntimeFlavor=$val")
      shift 2
      ;;

     -usemonoruntime)
      arguments+=("/p:PrimaryRuntimeFlavor=Mono")
      shift 1
      ;;

     -librariesconfiguration|-lc)
      if [ -z ${2+x} ]; then
        echo "No libraries configuration supplied. See help (--help) for supported libraries configurations." 1>&2
        exit 1
      fi
      passedLibConf="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
      case "$passedLibConf" in
        debug|release)
          val="$(tr '[:lower:]' '[:upper:]' <<< ${passedLibConf:0:1})${passedLibConf:1}"
          ;;
        *)
          echo "Unsupported libraries configuration '$2'."
          echo "The allowed values are Debug and Release."
          exit 1
          ;;
      esac
      arguments+=("/p:LibrariesConfiguration=$val")
      shift 2
      ;;

     -hostconfiguration|-hc)
      if [ -z ${2+x} ]; then
        echo "No host configuration supplied. See help (--help) for supported host configurations." 1>&2
        exit 1
      fi
      passedHostConf="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
      case "$passedHostConf" in
        debug|release|checked)
          val="$(tr '[:lower:]' '[:upper:]' <<< ${passedHostConf:0:1})${passedHostConf:1}"
          ;;
        *)
          echo "Unsupported host configuration '$2'."
          echo "The allowed values are Debug, Release, and Checked."
          exit 1
          ;;
      esac
      arguments+=("/p:HostConfiguration=$val")
      shift 2
      ;;

     -cross)
      crossBuild=1
      arguments+=("/p:CrossBuild=True")
      shift 1
      ;;

     *crossbuild=true*)
      crossBuild=1
      extraargs+=("$1")
      shift 1
      ;;

     -clang*)
      compiler="${opt/#-/}" # -clang-9 => clang-9 or clang-9 => (unchanged)
      arguments+=("/p:Compiler=$compiler" "/p:CppCompilerAndLinker=$compiler")
      shift 1
      ;;

     -cmakeargs)
      if [ -z ${2+x} ]; then
        echo "No cmake args supplied." 1>&2
        exit 1
      fi
      cmakeargs="${cmakeargs} $2"
      shift 2
      ;;

     -gcc*)
      compiler="${opt/#-/}" # -gcc-9 => gcc-9 or gcc-9 => (unchanged)
      arguments+=("/p:Compiler=$compiler" "/p:CppCompilerAndLinker=$compiler")
      shift 1
      ;;

     -targetrid|-outputrid)
      if [ -z ${2+x} ]; then
        echo "No value for targetrid is supplied. See help (--help) for supported values." 1>&2
        exit 1
      fi
      arguments+=("/p:TargetRid=$(echo "$2" | tr "[:upper:]" "[:lower:]")")
      shift 2
      ;;

     -portablebuild)
      if [ -z ${2+x} ]; then
        echo "No value for portablebuild is supplied. See help (--help) for supported values." 1>&2
        exit 1
      fi
      passedPortable="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
      if [ "$passedPortable" = false ]; then
        portableBuild=0
        arguments+=("/p:PortableBuild=false")
      fi
      shift 2
      ;;

     -keepnativesymbols)
      if [ -z ${2+x} ]; then
        echo "No value for keepNativeSymbols is supplied. See help (--help) for supported values." 1>&2
        exit 1
      fi
      passedKeepNativeSymbols="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
      if [ "$passedKeepNativeSymbols" = true ]; then
        arguments+=("/p:KeepNativeSymbols=true")
      fi
      shift 2
      ;;


      -ninja)
      if [ -z ${2+x} ]; then
        arguments+=("/p:Ninja=true")
        shift 1
      else
        ninja="$(echo "$2" | tr "[:upper:]" "[:lower:]")"
        if [ "$ninja" = true ]; then
          arguments+=("/p:Ninja=true")
          shift 2
        elif [ "$ninja" = false ]; then
          arguments+=("/p:Ninja=false")
          shift 2
        else
          arguments+=("/p:Ninja=true")
          shift 1
        fi
      fi
      ;;

      -pgoinstrument)
      arguments+=("/p:PgoInstrument=true")
      shift 1
      ;;

      -use-bootstrap)
      arguments+=("/p:UseBootstrap=true")
      shift 1
      ;;

      -bootstrap)
      bootstrap=1
      shift 1
      ;;

      -fsanitize)
      if [ -z ${2+x} ]; then
        echo "No value for -fsanitize is supplied. See help (--help) for supported values." 1>&2
        exit 1
      fi
      arguments+=("/p:EnableNativeSanitizers=$2")
      shift 2
      ;;

      -fsanitize=*)
      sanitizers="${opt/#-fsanitize=/}" # -fsanitize=address => address
      arguments+=("/p:EnableNativeSanitizers=$sanitizers")
      shift 2
      ;;

      -verbose)
      arguments+=("/p:CoreclrVerbose=true")
      shift 1
      ;;

      *)
      extraargs+=("$1")
      shift 1
      ;;
  esac
done

if [ ${#actInt[@]} -eq 0 ]; then
    arguments=("-restore" "-build" ${arguments[@]+"${arguments[@]}"})
fi

if [[ "$os" == "browser" ]]; then
    # override default arch for Browser, we only support wasm
    arch=wasm
    # because on docker instance without swap file, MSBuild nodes need to make some room for LLVM
    # https://github.com/dotnet/runtime/issues/113724
    # this is hexa percentage: 46-> 70%
    export DOTNET_GCHeapHardLimitPercent="46"
fi
if [[ "$os" == "wasi" ]]; then
    # override default arch for wasi, we only support wasm
    arch=wasm
fi

if [[ "${TreatWarningsAsErrors:-}" == "false" ]]; then
    arguments+=("-warnAsError" "false")
fi

# disable terminal logger for now: https://github.com/dotnet/runtime/issues/97211
arguments+=("-tl:false")

initDistroRid "$os" "$arch" "$crossBuild"

# Disable targeting pack caching as we reference a partially constructed targeting pack and update it later.
# The later changes are ignored when using the cache.
export DOTNETSDK_ALLOW_TARGETING_PACK_CACHING=0

# URL-encode space (%20) to avoid quoting issues until the msbuild call in /eng/common/tools.sh.
# In *proj files (XML docs), URL-encoded string are rendered in their decoded form.
cmakeargs="${cmakeargs// /%20}"
arguments+=("/p:TargetArchitecture=$arch" "/p:BuildArchitecture=$hostArch")
arguments+=("/p:CMakeArgs=\"$cmakeargs\"" ${extraargs[@]+"${extraargs[@]}"})

if [[ "$bootstrap" == "1" ]]; then
  # Strip build actions other than -restore and -build from the arguments for the bootstrap build.
  bootstrapArguments=()
  for argument in "${arguments[@]}"; do
    add=1
    for flag in --sign --publish --pack --test -sign -publish -pack -test; do
      if [[ "$argument" == "$flag" ]]; then
        add=0
      fi
    done
    if [[ $add == 1 ]]; then
      bootstrapArguments+=("$argument")
    fi
  done
  "$scriptroot/common/build.sh" ${bootstrapArguments[@]+"${bootstrapArguments[@]}"} /p:Subset=bootstrap -bl:$scriptroot/../artifacts/log/bootstrap.binlog

  # Remove artifacts from the bootstrap build so the product build is a "clean" build.
  echo "Cleaning up artifacts from bootstrap build..."
  rm -r "$scriptroot/../artifacts/bin"
  # Remove all directories in obj except for the source-built-upstream-cache directory to avoid breaking SourceBuild.
  find "$scriptroot/../artifacts/obj" -mindepth 1 -maxdepth 1 ! -name 'source-built-upstream-cache' -exec rm -rf {} +
  arguments+=("/p:UseBootstrap=true")
fi

"$scriptroot/common/build.sh" ${arguments[@]+"${arguments[@]}"}
