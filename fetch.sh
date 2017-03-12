#!/bin/sh
SERVER=news.eternal-september.org 
NNTP_USER=
NNTP_PASS=

# -Q - use NNTP_USER / NNTP_PASS
# -c update sucknewsrc
# -dd xxx data directory
# -dt xxx tmp directory
# -br xxx rnews batch
# -r xxx size limit for rnews batch files
# -y xxx filter program
suck $SERVER -Q -c -dd es/ -dt tmp -br out/es.rnews -r 10000 -y ./filter.pl

SERVER=news.gwene.org
NNTP_USER=
NNTP_PASS=
suck $SERVER -Q -c -dd gwene/ -dt tmp -br out/gwene.rnews -r 10000 -y ./filter.pl

###

# servers/es
# servers/gwene
# cat servers/es
# SERVER=
# NNTP_USER=
# NNTP_PASS=

mkdir tmp
mkdir out
mkdir msgs
for x in servers/* ; do
	SERVER=""
	NNTP_USER=""
	NNTP_PASS=""
	name=${x##servers/} #
	source "$x/config"
	suck $SERVER -Q -c -dd "$x" -dt tmp -dm msgs -br "out/${name}.rnews" -r 10000 -y ./filter.pl
done


for x in servers/* ; do

	# ${parameter##word} -- removes largest prefix.
	for k in $x/env/* ; do ${k##*/}=`cat "$k"`


done