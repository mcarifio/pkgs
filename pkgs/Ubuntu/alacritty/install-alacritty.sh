#!/usr/bin/env bash

me=$(realpath ${BASH_SOURCE})
here=$(dirname ${me})
source ${here}/../apt-functions.env.sh

apt-install --ppa=ppa:mmstick76/alacritty --auto alacritty



