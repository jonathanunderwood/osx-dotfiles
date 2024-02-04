# Homebrew packages for GNU uitilities etc that have the same name as OSX
# utilities install them in the path with a "g" prefix. This file adds the paths
# to the unprefixed commands to the PATH so that they are used instead of the
# OSX default utilities. This is necessary because Homebrew was removed all
# options from packages, includin g the --with-default-names option.

function env_append {
    # $1: environment variable name
    # $2: string to append
    # $3: delimiter to use between values

    local -n e="$1"
    local delim

    if [[ -z "$3" ]]; then
        delim=":"
    else
        delim="$3"
    fi


    if [[ -z "$e" ]]; then
        export "$1"="$2"
    else
        export "$1"="$e""$delim""$2"
    fi
}

function env_prepend {
    # $1: environment variable name
    # $2: string to prepend
    # $3: delimiter to use between values

    local -n e="$1"
    local delim

    if [[ -z "$3" ]]; then
        delim=":"
    else
        delim="$3"
    fi

    if [[ -z "$e" ]]; then
        export "$1"="$2"
    else
        export "$1"="$2""$delim""$e"
    fi
}

function env_prepend_dir {
    # $1: environment variable name
    # $2: directory to prepend if it exists and is a directory
    # $3: delimiter to use between values
    # $4: prefix for path

    local delim

    if [[ -z "$3" ]]; then
        delim=":"
    else
        delim="$3"
    fi

    if [[ -d "$2" ]]; then
        env_prepend "$1" "$4$2" "$delim"
    fi
}

function env_prepend_file {
    # $1: environment variable name
    # $2: directory to prepend if it exists and is a file
    # $3: delimiter to use between values

    local delim

    if [[ -z "$3" ]]; then
        delim=":"
    else
        delim="$3"
    fi

    if [[ -f "$2" ]]; then
        env_prepend "$1" "$2" "$delim"
    fi
}

if ! command -v brew > /dev/null 2>&1 ; then
    # If brew is not installed, or not on the PATH, then don't do anything.
    return 0
fi

# Many of the commands below could use brew --prefix <pkg> directly, and that
# would be more robust to package changes. But, to speed things up, we call brew
# --prefix once and store the path.
brew_path="$(brew --prefix)"

# List of packages which install their un-prefixed binaries outside of the PATH.
# Might be better to discover these automatically using find:
# find -L $(brew --prefix)/opt -type d -path */libexec/gnubin
# But, does that throw up stuff we don't want on the PATH?
brew_gnu_packages=(
    "coreutils"
    "ed"
    "findutils"
    "gawk"
    "gnu-indent"
    "gnu-sed"
    "gnu-tar"
    "gnu-which"
    "grep"
    "libtool"
    "make"
)

# Note that, rather than hardcoding the path /opt/$pkg here, we could instead
# use $(brew --prefix $pkg), but that's a very slow operation - 700 ms per
# package. For some reason, a bare $(brew --prefix) is much faster at finding
# the base install prefix.
for pkg in "${brew_gnu_packages[@]}"; do
    if [[ -d "$brew_path/opt/$pkg/libexec/gnubin" ]] ; then
        env_prepend PATH "$brew_path/opt/$pkg/libexec/gnubin"
        env_prepend_dir MANPATH "$brew_path/opt/$pkg/libexec/gnuman"
    fi
done

# These packages don't follow the gnubin/gnuman pattern above. Instead, they
# simply don't install symlinks into /usr/local/bin to their
# /usr/local/opt/pkg/bin because OSX comes with older versions.
brew_unlinked_packages=(
    # Note: do not put binutils on the path as it will subtly break Python
    # extensions. If you do at any point have this on the path and do any pip
    # installs, you'll probably end up with broken wheels that won't install. In
    # that case, do a `rm -rf ~/Library/Caches/pip` to prevent those broken
    # wheels being used for subsequent installs, and then reinstall all
    # packages.
    # "binutils"
    "bison"
    "openssl"
    "sqlite"
    "zip"
    "unzip"
    "curl"
)

for pkg in "${brew_unlinked_packages[@]}"; do
    if [[ -d "$brew_path/opt/$pkg/bin" ]]; then
        env_prepend PATH "$brew_path/opt/$pkg/bin"
        env_prepend_dir MANPATH "$brew_path/opt/$pkg/share/man"
    fi
done

# Setup compiler to use some brew installed libraries, if they're present. This
# is particularly important for allowing pip to build wheels locally. Note: an
# alternative strategy here could be to look for a pkgconfig file in the
# package, and if it's found add the library to LDFLAGS and CPPFLAGS. That would
# save the hassle of maintaining the list manually.
brew_libs=(
    "openssl"
    "sqlite"
    "openblas"
)

for pkg in "${brew_libs[@]}"; do
    if [[ -d "$brew_path/opt/$pkg" ]]; then
        env_prepend_dir LDFLAGS "$brew_path/opt/$pkg/lib" " " "-L"
        env_prepend_dir CPPFLAGS "$brew_path/opt/$pkg/include" " " "-I"
        env_prepend_file PKG_CONFIG_PATH "$brew_path/opt/$pkg/lib/pkgconfig"
    fi
done

# To build numpy wheels, the OPENBLAS environment variable needs to be set.
# See: https://github.com/numpy/numpy/issues/17807
if [[ -d "$brew_path/opt/openblas" ]]; then
    export OPENBLAS="$brew_path/opt/openblas"
fi
