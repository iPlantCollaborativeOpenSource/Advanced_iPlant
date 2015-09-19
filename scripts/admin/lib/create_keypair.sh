create_keypair () {

    local _KEYNAME=$1

    # Globals
    IAM_PEM=
    IAM_PRINT=

    RESPONSE=$(aws ec2 describe-key-pairs --key-name "${_KEYNAME}" 2> /dev/null)
    if [[ -n "$RESPONSE" ]];
    then
        warning "${_KEYNAME} already exists."
        #aws ec2 delete-key-pair --key-name "${_KEYNAME}"
    else
        RESPONSE=$(aws ec2 create-key-pair --key-name "${_KEYNAME}" 2> /dev/null)
        if [[ -n "$RESPONSE" ]];
        then
            IAM_PEM=$(echo "$RESPONSE" | jq -r .KeyMaterial)
            IAM_PRINT=$(echo "$RESPONSE" | jq -r .KeyFingerprint)
            success "Created keypair ${_KEYNAME} with fingerprint ${IAM_PRINT}"
            echo "$IAM_PEM" > "${_KEYNAME}.pem" && chmod 600 "${_KEYNAME}.pem"
        else
            warning "Key pair ${_KEYNAME} may not have been created."
        fi
    fi

}