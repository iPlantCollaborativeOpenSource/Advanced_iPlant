create_s3_bucket () {

    local BUCKET_NAME=$1
    local REGION=$2
    local RESPONSE=

    # Default region
    if [[ -z "${REGION}" ]]
    then
        REGION="us-east-1"
    fi

    RESPONSE=$(aws s3 ls "s3://${BUCKET_NAME}" 2> /dev/null)
    if [[ -n "${RESPONSE}" ]];
    then
        warning "s3://${BUCKET_NAME} already exists. Won't recreate it."
    else
        RESPONSE=$(aws s3 mb "s3://${BUCKET_NAME}" --region "${REGION}" 2> /dev/null)
        if [[ -n "${RESPONSE}" ]];
        then
            success "Created s3://${BUCKET_NAME}"
        else
            warning "Failed to create s3://${BUCKET_NAME}"
        fi
    fi

}

delete_s3_bucket () {

    local BUCKET_NAME=$1
    local RESPONSE=

    RESPONSE=$(aws s3 ls "s3://${BUCKET_NAME}" 2> /dev/null)
    if [[ -z "${RESPONSE}" ]];
    then
        warning "Can't list s3://${BUCKET_NAME} - does it really exist?"
        RESPONSE=$(aws s3 rb "s3://${BUCKET_NAME}" --force 2> /dev/null)
        log "$RESPONSE"
    fi
}
