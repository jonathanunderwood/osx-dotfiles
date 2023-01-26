function setup_ssh_key {
    # Create/replace an SSH leypair and load into the ssh-agent
    local output_key_file=~/.ssh/id_ed25519

    read -p "Identity (email) for key: " identity
    ssh-keygen -t ed25519 -C "${identity}" -f "${output_key_file}"

    ssh-add --apple-use-keychain "${output_key_file}"
}
