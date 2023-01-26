# .bash_profile

# Source aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Setup Homebrew
if [[ -e /opt/homebrew/bin/brew ]] ; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Source files . .profile.d if they have a .sh extension
for i in ~/profile.d/*.sh ; do
    if [ -r "$i" ]; then
        . "$i"
    fi
done
unset i

