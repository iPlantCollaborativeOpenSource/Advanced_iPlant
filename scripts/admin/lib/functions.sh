CDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Must come first
source "$CDIR/_common.sh"

# Things that depend on common go here
source "$CDIR/create.sh"
source "$CDIR/policy.sh"
source "$CDIR/groupadd.sh"
source "$CDIR/setpass.sh"
source "$CDIR/create_apikeys.sh"
source "$CDIR/create_keypair.sh"
source "$CDIR/persist_meta.sh"
source "$CDIR/delete.sh"

