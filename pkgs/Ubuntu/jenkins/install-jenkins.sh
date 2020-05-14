#!/usr/bin/env bash

me=$(realpath ${BASH_SOURCE})
here=$(dirname ${me})
source ${here}/../apt-functions.env.sh
pkg=$(inside '^install-(.+)$' $(basename ${me} .sh))
apt-install --repo='deb http://pkg.jenkins.io/debian-stable binary/' ${pkg}

