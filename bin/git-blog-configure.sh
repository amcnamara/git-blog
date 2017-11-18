function configure_social() {
    # Configure social handles only if they don't already exist
    if grep -qE "twitter|facebook|email" $CONFIG_FILE; then
        pwarning "A config file with social handles already exists, please edit $CONFIG_FILE directly"
    else
        pbold "Please enter your twitter handle (or leave blank):"
        read -e twitter
        pbold "Please enter your facebook handle (or leave blank):"
        read -e facebook
        pbold "Please enter your email address (or leave blank):"
        read -e email

        if [[ ! -z $twitter || ! -z $facebook || ! -z $email ]]; then
            cat >> $CONFIG_FILE <<CONF
---
twitter: $twitter
facebook: $facebook
email: $email
---
CONF
        fi
    fi
}

function configure_upstream() {
    # Configure blog endpoint if it isn't already present
    if grep -qE "location|region" $CONFIG_FILE; then
        pwarning "A config file with an S3 endpoint already exsits, please edit $CONFIG_FILE directly"
    else
        pbold "Please enter the AWS region where your blog is hosted:"
	read -e region
	pbold "Please enter the ARN of the S3 bucket where your blog is hosted:"
        read -e bucket
	
	if [[ ! -z $bucket && ! -z $region ]]; then
            pwarning "No bucket location or region provided, please provision $CONFIG_FILE before publishing"
        else
            cat >> $CONFIG_FILE <<CONF
---
region: $region
location: $bucket
---
CONF
        fi
    fi
}

function configure_aws() {
    # Initialize AWS token
    if [ -e $AWS_TOKEN_FILE ]; then
        pbold "Please enter your AWS access token (or leave blank to keep existing token):"
    else
        pbold "Please enter your AWS access token:"
    fi
    read -s -e token

    if [ -z $token ]; then
        if [ -e $AWS_TOKEN_FILE ]; then
	    echo "No token provided, a credential already exists at $AWS_TOKEN_FILE and hos not been changed"
        else
            pwarning "No token provided, please provision $AWS_TOKEN_FILE before publishing"
        fi
    else
        echo "Writing token to $AWS_TOKEN_FILE"
        echo "${YELLOW}Please be careful not to check-in or otherwise make this credential public!${NOCOLOUR}"
        echo $token > $AWS_TOKEN_FILE
    fi
}

function configure() {
    configure_social
    configure_upstream
    configure_aws
}
