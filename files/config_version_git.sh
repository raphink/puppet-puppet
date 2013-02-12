#!/bin/bash

ENVIRONMENT=$1

[[ -z $ENVIRONMENT ]] && echo "UNKNOWN ENVIRONMENT" && exit 0

augmanifestdir=$(augtool --noautoload \
	              --transform "Puppet.lns incl /etc/puppet/puppet.conf" \
		      match "/files/etc/puppet/puppet.conf/$ENVIRONMENT/manifestdir" \
                | grep -v '(no matches)')

[[ $? != 0 ]] && echo "UNKNOWN MANIFESTDIR" && exit 0

manifestdir=$(cut -d= -f2 <<<$augmanifestdir)

[[ -z $manifestdir ]] && echo "UNKNOWN MANIFESTDIR" && exit 0

gitdir=$(dirname "$manifestdir")

echo -n "$ENVIRONMENT/"
cd $gitdir && echo -n $(git rev-parse --short HEAD)

cd $gitdir && git diff-files --quiet --ignore-submodules --
[[ $? == 0 ]] || echo -n " [+]"

echo
