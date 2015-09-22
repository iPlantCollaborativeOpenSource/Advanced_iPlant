persist_metadata () {

    # Relies on globals
    local _FNAME=$1
    local _MID=$2
    local _ANAME=$3

    log "Updating metadata record $_MID"

    # Search and update if already found
    MQ="%7B%22name%22%3A%22${_MID}%22%7D"
    META_SEARCH=$(metadata-list -Q $MQ)
    RESULT=$(metadata-addupdate -F ${_FNAME} ${META_SEARCH} 2> /dev/null)

    # Grant the user READ on his or her record
    META_SEARCH=$(metadata-list -Q $MQ)
    metadata-pems-addupdate -u ${_ANAME} -p READ ${META_SEARCH}
    # Manually grant other instructors READ on record
    # This should be abstracted to be configurable and tenant-agnostic
    metadata-pems-addupdate -u jfonner -p READ ${META_SEARCH}
    metadata-pems-addupdate -u nirav   -p READ ${META_SEARCH}

}