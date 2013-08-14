#!/bin/bash
# usage : $1 is with, or without, xdebug ( i.e. clean, xdebug )

OPTION=$1

if [ "aa$1" == "aa" ]; then
    echo "You must specify if you want with, or without, xdebug"
    echo "Example: $./startup.sh clean or $./startup.sh xdebug"
    exit 1
fi

function choice
{
    case "$OPTION" in
        clean)
            option;;
        xdebug)
            option;;
        *)
            echo "choice not valid, has to be clean or xdebug";;
    esac
}

function option
{
    mv 'vagrant/Vagrantfile-'$OPTION 'Vagrantfile'
#    vagrant up
}

choice