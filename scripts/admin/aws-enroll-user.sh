# Automated AWS account provisioning
# for Agave platform users

# agave
UNAME=$1
GROUP=$2

FDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${FDIR}/config.sh"
source "${FDIR}/lib/functions.sh"

confirm_user_provided "{$UNAME}" "${AGAVE_TENANTID}"
validate_agave_user "${UNAME}"
validate_aws_group "${GROUP}" "${UNAME}"

create_user "${IAM_USER}"
attach_policy "${IAM_USER}" "${IAM_GRUPO}" "${S3_BUCKET_NAME}"
init_password "${IAM_USER}"

# assets
create_apikeys "${IAM_USER}"
create_keypair "${IAM_KEYNAME}"
create_s3_bucket "${S3_BUCKET_NAME}" "${AWS_REGION}"

# Only write the metadata record if we have all the secrets in hand
if [[ -n "${IAM_PEM}" ]] && [[ -n "${IAM_SECRET}" ]] && [[ -n "${IAM_PASS}" ]];
then

log "Writing Metadata file..."

IAM_PEM_ESC=$(jsonpki.sh --private ${IAM_KEYNAME}.pem)

sh -c "cat > Meta.json" <<META
{ "name":"${AGAVE_META_ID}",
  "value": {
    "identity": {
        "iam_user": "${IAM_USER}",
        "iam_password": "${IAM_PASS}",
        "iam_group": "${IAM_GRUPO}"
    },"apikeys": {
        "key": "${IAM_KEY}",
        "secret": "${IAM_SECRET}"
    },"sshkeys": {
        "keypair": "${IAM_KEYNAME}",
        "fingerprint": "${IAM_PRINT}",
        "pem": "${IAM_PEM_ESC}"
    },"aws": {
        "uri": "http://${AWS_PROJECT}.signin.aws.amazon.com/console",
        "region": "${AWS_REGION}"
    }
  }
}
META

persist_metadata Meta.json "${AGAVE_META_ID}" "${UNAME}"
rm -rf Meta.json

fi

create_group "${IAM_GRUPO}"
group_add "${IAM_USER}" "${IAM_GRUPO}"
