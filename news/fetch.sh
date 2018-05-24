#!/bin/bash

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
PATH=$PATH:/usr/local/bin/

mkdir -p tmp
mkdir -p out
mkdir -p msgs
for x in servers/* ; do
	NNTP_SERVER=""
	NNTP_USER=""
	NNTP_PASS=""
	SUCK_FILTER_FLAGS=""
	SUCK_FLAGS=""
	name=${x##servers/}
	if [ -e "$x/config.sh" ] ; then . "$x/config.sh" ; fi
	if [ -n "$NNTP_SERVER" ] ; then
		echo "Reading ${name}"
		export NNTP_USER NNTP_PASS SUCK_FILTER_FLAGS
		suck $NNTP_SERVER $SUCK_FLAGS -r 32768 -Q -c -dd "$x" -dt tmp -dm msgs -HF "$x/history" \
		-br "out/${name}.rnews" -y ./filter.pl
		unset -v NNTP_USER NNTP_PASS SUCK_FILTER_FLAGS
	fi
done

echo "Sending rnews"
for x in out/*.rnews ; do
	umdss-mail -s "rnews batch" -f umdss rnews@pro-kegs "$x" && rm "$x"
done
