# Check Agave tenant user provided
confirm_user_provided () {

    local _USER=$1
    local _TENANT=$2

    if [[ -z "$_USER" ]];
    then
        failure "Please provide a ${_TENANT} username!"
    fi

}

# Validate Agave tenant user
validate_agave_user () {

    local _USER=$1
    log "Validating Agave platform user ${_USER}..."
    local RESPONSE=
    RESPONSE=$(profiles-list "${_USER}" 2> /dev/null)
    if [[ -n "$RESPONSE" ]];
    then
        success "User ${_USER} found. Email address: ${RESPONSE}"
    else
        failure "No Agave platform user ${_USER} found"
    fi
}

# Create IAM user
create_user () {

    local _USER=$1
    log "Creating user ${_USER}..."
    local RESPONSE=
    local IAM_UID=

    # First check to see if IAM user exists
    RESPONSE=$(aws iam get-user --user-name "${_USER}" 2> /dev/null)
    if [[ -n "$RESPONSE" ]];
    then
        warning "User ${_USER} appears to exist already"
    else
        RESPONSE=$(aws iam create-user --user-name "${_USER}" 2> /dev/null)
        #log "$RESPONSE"
        if [[ -n "$RESPONSE" ]];
        then
            IAM_UID=$(echo "$RESPONSE" | jq -r .User.UserId)
            success "Created IAM user ${_USER} (${IAM_UID})"
        else
            warning "Attempt to create user ${_USER} may not have been successful."
        fi
    fi

}

# Validate AWS group was provided
validate_aws_group () {

    local _GROUP=$1
    local _UNAME=$2

    if [[ -z "${_GROUP}" ]];
    then
        failure "Please specify a group name that the ${_UNAME} should be assigned to"
    fi
}