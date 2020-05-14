apt-install() {
    local -a _args=( $* )
    local -a _positionals
    # initial (default) values for vars, especially command line switches/flags.
    local key='' # --key=${url}
    local ppa='' # --ppa=${url}
    local repo='' # --repo=${url}
    declare -i need_update=1
    
    while (( ${#*} )); do
        local _it=${1}
        case "${1}" in
            --) shift; _positionals+=($*); break;;
            --key=*) key=${_it#--key=}; shift;;
            --ppa=*) ppa=${_it#--ppa=}; shift;;
            --repo=*) repo=${_it#--repo=}; shift;;
            *) _positionals+=(${_i}); shift;;
        esac
    done

    if [[ -n "${key}" ]] ; then
        curl -L ${key} | sudo apt-key add -
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
    if (( need_update )) ; then apt update ; fi
    apt upgrade -y
    for p in ${_positionals[*]} ; do dpkg --list ${p} &> /dev/null || apt install -y ${p} ; done
}

inside() {
    local _re=${1:?'expecting a regular expression'}
    local _s=${2:?'expecting a string'}
    if [[ "${_s}" =~ ${_re} ]] ; then echo ${BASH_REMATCH[1]} ; fi
}
 
