#!/usr/bin/env bash

# strict mode, http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -ueo pipefail
IFS=$'\n\t'

_me=$(realpath ${BASH_SOURCE})
_here=$(dirname ${_me})
_name=$(basename ${_me})

# http://bashdb.sourceforge.net/bashdb.html
# Richer 'set -x' output; doesn't seem to work.
# PS4='(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]} - [${SHLVL},${BASH_SUBSHELL}, $?]'

_version() {
    local v=${me}.version.txt
    if [[ -r ${v} ]] ; then
        cat -s ${v}
    else
        echo "0.1.1"
    fi
}

_say_version() {
    echo "${_name} $(_version) # at ${_me}"
    exit 0
}

_help() {
    echo "help ${_name} $(_version) # at ${_me}"
    exit 0
}

_usage() {
    echo "usage: ${_name} [-h|--help] [-v|--version] [-u|--usage]  # at ${_me}"
    exit 1
}

_error() {
    local _status=${2:-1}
    local _message=${1-"${_me} error ${_status}"}
    echo ${_message} > /dev/stderr
    exit 1
}

_on_exit() {
    local _status=$?
    # cleanup here
    exit ${_status}
}

# trap -l to enumerate signals
trap _on_exit EXIT

# Typically used to rerun this command as root via sudo.
_run_as() {
    declare -i uid=${1:-0}
    if (( uid -u != ${uid} )) ; then
        echo "${me} requires '${uid}'. Rerunning..." > /dev/stderr
        exec sudo -i -u ${uid} "$*"
    fi
}

sudo-nopasswd() {
    local nopasswd=/etc/sudoers.d/nopasswd
    [[ -f ${nopasswd} ]] || echo "%sudo ALL = (ALL) NOPASSWD: ALL" > ${nopasswd}
    for u in $*; do usermod -G sudo ${u}; done
    [[ -n "${SUDO_USER}" ]] && usermod -G sudo ${SUDO_USER}
}


_start() {
    local -a _args=( $* )
    local -a _positionals
    # initial (default) values for vars, especially command line switches/flags.

    while (( ${#*} )); do
        local _it=${1}
        case "${1}" in
            -h|--help) _help; break;;
            -v|--version) _say_version; break;;
            -u|--usage) _usage; break;;
            --) shift; _positionals+=($*); break;;
            -*|--*) _error "$1 unknown flag"; break;;
            *) positionals+=(${_i}); shift;;
        esac
    done

    sudo-nopasswd
    apt-install mysql-server
postgresql
mysql-workbench
shutter
dia blender
jenkins # https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu
python-software-properties
nodejs
pip3 install ansible
python3-pip
meld
youtube-dl
tree
awscli

}


_run_as 0
source ${here}/apt-functions.env.sh
_start $@

