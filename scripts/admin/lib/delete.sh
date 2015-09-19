delete_user () {

    local _USER=$1
    local RESPONSE=

    log "Starting user delete on ${_USER}..."

    # Singular
    aws iam delete-login-profile --user-name ${_USER} 2> /dev/null

    # Theoretically multiple but for this code we only have one policy
    aws iam delete-user-policy --user-name ${_USER} --policy-name "${_USER}.access" 2> /dev/null

    # Remove from groups
    for G in $(aws iam list-groups-for-user --user-name ${_USER} | jq -r .Groups[].GroupName)
    do
        log "Removing user ${_USER} from group $G "
        aws iam remove-user-from-group --user-name ${_USER} --group-name ${G}
    done

    # Remove API keys
    for K in $(aws iam list-access-keys --user-name ${_USER} | jq -r .AccessKeyMetadata[].AccessKeyId)
    do
        log "Deleting API key $K..."
        aws iam delete-access-key --access-key-id $K --user-name ${_USER}
    done

    RESPONSE=$(aws iam delete-user --user-name ${_USER} 2> /dev/null)
    log "${RESPONSE}"

}

delete_keypair () {

    local _KEYNAME=$1
    log "Deleting SSH key-pair $_KEYNAME..."

    RESPONSE=$( aws ec2 delete-key-pair --key-name ${_KEYNAME} 2> /dev/null )
    log "$RESPONSE"

}

delete_metadata () {

    # Relies on globals
    local _MID=$1
    log "Deleting metadata name:$_MID"
    # Search and update if already found
    MQ="%7B%22name%22%3A%22${_MID}%22%7D"
    META_SEARCH=$(metadata-list -Q $MQ)
    metadata-delete ${META_SEARCH} 2> /dev/null

}

