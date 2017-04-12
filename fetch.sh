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
	FLAGS=""
	name=${x##servers/}
	if [ -e "$x/config.sh" ] ; then . "$x/config.sh" ; fi
	if [ -n "$NNTP_SERVER" ] ; then
		echo "Reading ${name}"
		NNTP_USER="$NNTP_USER" NNTP_PASS="$NNTP_PASS" \
		suck $NNTP_SERVER $FLAGS -Q -c -dd "$x" -dt tmp -dm msgs -HF "$x/history" \
		-br "out/${name}.rnews" -y ./filter.pl
	fi
done

echo "Merging rnews"
RNEWS=/var/spool/umdss/out/localhost/.tmp/rnews
if [ ! -e "$RNEWS" ] ; then printf "To: rnews\n\n" > "$RNEWS" ; fi
cat out/*.rnews >> "$RNEWS"
rm out/*.rnews

TMP=`mktemp -u /var/spool/umdss/out/localhost/XXXXXX`
for x in 1 2 3 4 5 ; do
	mv -n "$RNEWS" "$TMP" && break
	TMP=`mktemp -u /var/spool/umdss/out/localhost/XXXXXX`
done

