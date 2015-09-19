# Create an IAM group
create_group () {

    local _GROUP=$1
    log "Creating group ${_GROUP}..."
    local RESPONSE=
    local IAM_GID=

    RESPONSE=$(aws iam get-group --group-name "${_GROUP}" 2> /dev/null)
    if [[ -n "$RESPONSE" ]];
    then
        warning "Group ${_GROUP} already exists."
    else
        RESPONSE=$(aws iam create-group --group-name "${_GROUP}" 2> /dev/null)
        if [[ -n "$RESPONSE" ]];
        then
            IAM_GID=$(echo "$RESPONSE" | jq -r .Group.GroupId)
            success "Created IAM group ${_GROUP} ($IAM_GID)"
        else
            warning "Group ${_GROUP} may not have been created."
        fi
    fi

}

# Add user to IAM group
group_add () {

    local _USER=$1
    local _GROUP=$2
    log "Adding ${_USER} to ${_GROUP}..."
    RESPONSE=
    RESPONSE=$(aws iam add-user-to-group --user-name "${_USER}" --group-name "${_GROUP}" 2> /dev/null)
    log "${RESPONSE}"
    if [[ ! -n "$RESPONSE" ]];
    then
        success "${_USER} added to ${_GROUP}"
    else
        warning "Adding ${_USER} to ${_GROUP} may not have been successful."
    fi

}

