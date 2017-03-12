#!/bin/sh

# suck flags:
# -Q - use NNTP_USER / NNTP_PASS
# -c update sucknewsrc
# -dd xxx data directory
# -dt xxx tmp directory
# -br xxx rnews batch
# -r xxx size limit for rnews batch files
# -y xxx filter program

#
# directory layout:
# servers/[name]/config.sh
# servers/[name]/sucknewsrc
# 
# where name is something short (so [name].rnews will be a valid ProDOS name)
# config.sh should look like:
# NNTP_SERVER=....
# NNTP_USER=...
# NNTP_PASS=...
#

mkdir -p tmp
mkdir -p out
mkdir -p msgs
for x in servers/* ; do
	NNTP_SERVER=""
	NNTP_USER=""
	NNTP_PASS=""
	name=${x##servers/}
	if [ -e "$x/config.sh" ] ; then . "$x/config.sh" ; fi
	if [ -n "$NNTP_SERVER" ] ; then
		echo "Reading ${name}"
		suck $NNTP_SERVER -Q -c -dd "$x" -dt tmp -dm msgs -br "out/${name}.rnews" -r 10000 -y ./filter.pl
	fi
done
