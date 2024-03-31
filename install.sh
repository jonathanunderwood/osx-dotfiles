#!/usr/bin/env bash

# Use GNU stow to install symlinks to the configurations.
configs=(
    bash
    spacemacs
    ssh
)

for config in "${configs[@]}"; do
    stow -t "${HOME}" "${config}"
done
