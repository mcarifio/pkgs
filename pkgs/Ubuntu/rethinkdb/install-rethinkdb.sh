#!/usr/bin/env bash
me=$(realpath ${BASH_SOURCE})
here=${me%/*}

rethinkdb_list=/etc/apt/sources.list.d/rethinkdb.list
[[ -f ${rethinkdb_list} ]] || echo "deb http://download.rethinkdb.com/apt $(lsb_release -sc) main" > ${rethinkdb_list}
( apt-key list | grep
  rethinkdb - ) || wget -qO- https://download.rethinkdb.com/apt/pubkey.gpg | sudo apt-key add-
apt update
apt install --upgrade rethinkdb
