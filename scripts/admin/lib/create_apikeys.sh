create_apikeys () {

    local _USER=$1
    log "Creating API keys for ${_USER}"
    local RESPONSE=

    # These are defined as globals outside our function but
    # this is a reminder to set them
    IAM_KEY=
    IAM_SECRET=

    # Check for existence of key(s) first
    RESPONSE=$(aws iam list-access-keys --user-name "${_USER}" 2> /dev/null)
    if [[ -n "$RESPONSE" ]];
    then
        FOUND_KEY=$(echo "$RESPONSE" | jq -r .AccessKeyMetadata[0].AccessKeyId)
        if [[ "${FOUND_KEY}" != "null" ]];
        then
            warning "Found an existing key ${FOUND_KEY} for ${_USER}"
        else
            RESPONSE=$(aws iam create-access-key --user-name "${_USER}" 2> /dev/null)
            if [[ -n "$RESPONSE" ]];
            then
                # Global variables
                IAM_KEY=$(echo "$RESPONSE" | jq -r .AccessKey.AccessKeyId)
                IAM_SECRET=$(echo "$RESPONSE" | jq -r .AccessKey.SecretAccessKey)
                success "${_USER} has been granted access key ${IAM_KEY}"
            else
                warning "Access key for ${IAM_USER} may not have been granted."
            fi
        fi
    fi
}
