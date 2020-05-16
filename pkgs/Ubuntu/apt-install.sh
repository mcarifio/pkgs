#!/usr/bin/env bash
# @author: Mike Carifio <mike@carif.io>
# -*- mode: shell-script; eval: (message "tab-width: %d, indent with %s" tab-width (if indent-tabs-mode "tabs (not preferred)" "spaces (preferred)")) -*- 

# Note that emacs can be configured for [editorconfig](https://editorconfig.org/)
#   with [editorconfig-emacs](https://github.com/editorconfig/editorconfig-emacs)

set -euo pipefail
IFS=$'\n\t'

_me=$(realpath ${BASH_SOURCE})
_here=$(dirname ${_me})
_name=$(basename ${_me})


if [[ $(id -un) != root ]] ; then
    exec sudo -i ${_me} $@
fi


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
    local uid=${1:-root}
    local _id=$(id -un)
    if [[ ${_id} != ${uid} ]] ; then
        exec sudo -i -u ${uid} "$*"
    fi
}

# Explicit dispatch to an entry point, _start by default.
_dispatch() {
    
    local _entry=_start
    declare -a _args=() # don't pass --start to "real" function

    while (( ${#*} )); do
        local _i=${1}
        case "${_i}" in
            -h|--help) _help;;
            -v|--version) _say_version;;
            -u|--usage) _usage;;
            # new entry point, --start=${USERNAME} dispatches to _start_mcarifio with all arguments
            --start=*) _entry=_start_${_i#--start=} ; shift ;;
            *) _args+=(${_i}) ; shift ;;
        esac
    done

    ${_entry} ${_args[*]}
}


_inside() {
    local _r
    e=${1:?'expecting a regular expression'}
    local _s=${2:?'expecting a string'}
    if [[ "${_s}" =~ ${_re} ]] ; then echo ${BASH_REMATCH[1]} ; fi
}



_start() {
    local -a _args=( $* )
    local -a _positionals
    # initial (default) values for vars, especially command line switches/flags.

    local key='' # --key=${url}
    local ppa='' # --ppa=${url}
    local repo='' # --repo=${url}
    declare -i need_update=1
    declare -i quiet=1
    
    while (( ${#*} )); do
        local _it=${1}
        case "${1}" in
            --) shift; _positionals+=($*); break;;
            --loud) quiet=0; shift;;
            --key=*) key=${_it#--key=}; shift;;
            --ppa=*) ppa=${_it#--ppa=}; shift;;
            --repo=*) repo=${_it#--repo=}; shift;;
            *) _positionals+=(${_i}); shift;;
        esac
    done

    if [[ -n "${key}" ]] ; then
        curl -L ${key} | apt-key add -
        echo "key ${key} installed." > /dev/stderr
    fi
    
    
    if [[ -n "${ppa}" ]] ; then
        local name=${ppa#ppa:}
        if ! (apt policy 2>&1|grep ${name} > /dev/null) ; then
            add-apt-repository -y ${ppa}
        fi
        need_update=0
    fi

    if [[ -n "${repo}" ]] ; then
        local source_list=/etc/apt/sources.list.d/${positionals[0]}.list
        echo "${repo}" > ${source_list}
        [[ -f ${source_list} ]] && echo "Created ${source_list}"
    fi
    
    # install key
    # add repo and/or ppa
    if (( need_update )) ; then apt update &> /dev/null ; fi
    sudo apt upgrade -y
    for p in ${_positionals[*]} ; do
        if ! dpkg --list ${p} &> /dev/null && apt show ${p} &> /dev/null ; then
            apt install -y ${p}
        fi
    done
    
    apt-mark showmanual | install --backup=numbered -T -o $(stat --printf="%U" ${_me}) -g $(stat --printf="%G" ${_me}) /dev/stdin ${_here}/pkgs.list.text
}

 
# <script> --start=echo * # @advise:bash:inspect: a useful smoketest
_start_echo() {
    echo "$*"
}


_dispatch $@


