# Requiired environment variables for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Projects

# Setup pyenv for managing python versions
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

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
    pip install jupyter notebook jupyter_contrib_nbextensions
    # Enable extensions. The --sys-prefix ensures that the extensions are
    # configured in the current virtualenv rather than at a system level (which
    # is what happens without this option).
    jupyter contrib nbextension install --sys-prefix
    # Extensions to enable. Note to list what is enabled, run:
    # jupyter nbextension list
    jupyter nbextension enable --sys-prefix collapsible_headings/main

    pip install autopep8
    jupyter nbextension enable --sys-prefix code_prettify/autopep8

    pip install yapf
    jupyter nbextension enable --sys-prefix code_prettify/code_prettify
    # Don't enable lux for now - it's very buggy
    # pip install lux-api
    # jupyter nbextension install --py luxwidget
    # jupyter nbextension enable --py luxwidget
}
