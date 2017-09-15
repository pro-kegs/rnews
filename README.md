# rnews
rnews configuration for pro-kegs

## Dependencies:

* `maildrop` (Mail filter)
* `suck` (NNTP utility)
* `umdss-mail` (UMDSS utility)

## Reading NNTP

`news/fetch.sh` is run by a cron job to retrieve new messages from NNTP servers (defined in the `news/servers/` directory).

## Writing NNTP

Mail is sent to the rnews user.  The maildrop filter checks for a `Newsgroups:` header and posts to NNTP. (via the eternal september NNTP server).


