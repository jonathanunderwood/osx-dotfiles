
function spacemacs_update {
    # Update spacemacs and elisp packages. The package update command is ran
    # twice to ensure packages are unpacked and compiled.
    printf "Updating spacemacs:\n"
    git -C ~/.emacs.d/ pull || { printf "Failed to update spacemacs\n" ; exit 1 ; }
    printf "Spacemacs updated.\n\n"

    printf "Updating packages:\n"
    for i in seq 1 2; do
        emacs --batch -l ~/.emacs.d/init.el --eval="(configuration-layer/update-packages t)" || { printf "Failed to update spacemacs packages\n" ; exit 1 ; }
    done
    printf "Packages updated. Exiting.\n"
}
