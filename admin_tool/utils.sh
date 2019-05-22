#!/bin/bash

is_array() {
    local array_name="$1"
    if [[ "$(declare -p $array_name)" =~ 'declare -a ' ]] || \
       [[ "$(declare -p $array_name)" =~ 'typeset -g -a ' ]] || \
       [[ "$(declare -p $array_name)" =~ 'typeset -a ' ]] ; then
        echo true
    else
        echo false
    fi
}