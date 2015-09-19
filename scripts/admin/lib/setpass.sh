init_password () {

    local _USER=$1
    log "Initializing LoginProfile with password for ${_USER}..."
    local RESPONSE=
    RESPONSE=$(aws iam get-login-profile --user-name "${_USER}" 2> /dev/null)
    if [[ -n "$RESPONSE" ]];
    then
        warning "IAM LoginProfile seems to already exist for ${IAM_USER}"
    else
        IAM_PASS=$(openssl rand -base64 32  | cut -c1-24)
        RESPONSE=$(aws iam create-login-profile --user-name "${_USER}" --password "${IAM_PASS}" 2> /dev/null)
        #log "$RESPONSE"
        if [[ -n "$RESPONSE" ]];
        then
            success "IAM LoginProfile established for ${IAM_USER}"
            log "Password: $IAM_PASS"
        else
            warning "Attempted creation of LoginProfile established for ${IAM_USER} may not have succeeded."
        fi
    fi

}

