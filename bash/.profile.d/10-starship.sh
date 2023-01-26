
if command -v starship &> /dev/null; then
    export STARSHIP_CONFIG=~/Library/Application\ Support/starship/starship.toml
    eval "$(starship init bash)"
fi
