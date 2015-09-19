AGAVE_CLI=$(which auth-tokens-refresh)
if [[ -z "$AGAVE_CLI" ]];
then
    echo "Please install and configure the \x1B[1mAgave cli\x1B[0m"
    exit 1
fi

auth-tokens-refresh -S
AGAVE_TENANTID=$(auth-check -v | jq -r .tenantid)

# AWS Globals
AWS_PROJECT="iplant-aws"
AWS_REGION="us-west-1"
# User identity. GROUP and UNAME are initialized elsewhere
IAM_GRUPO="${GROUP}"
IAM_USER="${UNAME}.${AGAVE_TENANTID}"
IAM_PASS=
# apikeys
IAM_KEY=
IAM_SECRET=
# pem
IAM_PEM=
IAM_PRINT=
IAM_KEYNAME="${IAM_GRUPO}.${UNAME}"

# User-specific key for storing a credential document in Agave document store
AGAVE_META_ID="${AWS_PROJECT}.${IAM_KEYNAME}"
