# Requiired environment variables for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Projects

# # Setup pyenv for managing python versions
# if command -v pyenv 1>/dev/null 2>&1; then
#     export PYENV_ROOT="$HOME/.pyenv"
#     export PATH="$PYENV_ROOT/bin:$PATH"
#     eval "$(pyenv init -)"
# fi

# # Setup pyenv to use the Homebrew installed python packages.
# # See: https://stackoverflow.com/questions/30499795/how-can-i-make-homebrews-python-and-pyenv-live-together
# rm -f "$HOME/.pyenv/versions/*-brew"
# for i in $(brew --cellar)/python* ; do
#     for p in "$i"/*; do
#         # echo $p
#         ln -s -f "$p" "$HOME/.pyenv/versions/${p##/*/}-brew"
#     done
# done
# pyenv rehash

# Find the latest python
if command -v python3 > /dev/null 2>&1 ; then
    python=$(command -v python3)
    pyver=$(python3 -c "import sys; print('{0}.{1}'.format(sys.version_info.major, sys.version_info.minor))")
elif command -v python > /dev/null 2>&1 ; then
    python=$(command -v python)
    pyver=$(python -c "import sys; print('{0}.{1}'.format(sys.version_info.major, sys.version_info.minor))")
else
    return 0
fi

# Don't do this: it will override what the virtualenv activate script does to
# put the virtualenv python at the start of the path when the virtualenv is
# activated.
# alias python="$python"

# Add the bin directory that is used for when a `pip install --user <pkg>`
# command installs something executable.
user_bindir="$HOME/Library/Python/$pyver/bin"
export PATH="$user_bindir":"$PATH"

# If we have installed virtualenvwrapper, source its setup file. But only do
# this if not already in a virtualenv (e.g. in a peotery shell).
wrapper=$(command -v virtualenvwrapper.sh)

if [[ -f "$wrapper" ]] && [[ -z "$VIRTUAL_ENV" ]]; then
    export VIRTUALENVWRAPPER_PYTHON="$python"
    source "$wrapper"
fi

function reinstall_virtualenvwrapper {
    # When Python is upgraded, it's necessary to reinstall virtualenvwrapper,
    # because when it is installed it installs a hook loader for the discovered
    # version of Python.
    pip3 install --user --force-reinstall -U virtualenvwrapper
}

function poetry_venv_setup_dev_tools {
    # This function adds packages to a poetry virtualenv that are required for
    # spacemacs to use lsp mode for Python.
    # See: https://develop.spacemacs.org/layers/+lang/python/README.html
    poetry run pip install importmagic epc python-lsp-server[all] # pyright
}

function setup_jupyter {
    poetry run pip install jupyter notebook jupyter_contrib_nbextensions
    # Enable extensions. The --sys-prefix ensures that the extensions are
    # configured in the current virtualenv rather than at a system level (which
    # is what happens without this option).
    poetry run jupyter contrib nbextension install --sys-prefix
    # Extensions to enable. Note to list what is enabled, run:
    # jupyter nbextension list
    poetry run jupyter nbextension enable --sys-prefix collapsible_headings/main

    poetry run pip install autopep8
    poetry run jupyter nbextension enable --sys-prefix code_prettify/autopep8

    poetry run pip install yapf
    poetry run jupyter nbextension enable --sys-prefix code_prettify/code_prettify
    # Don't enable lux for now - it's very buggy
    # pip install lux-api
    # jupyter nbextension install --py luxwidget
    # jupyter nbextension enable --py luxwidget
}

function setup_python_devtools {
    poetry add --dev black isort pylint flake8
    poetry run pip install pyright autoflake importmagic epc
}
