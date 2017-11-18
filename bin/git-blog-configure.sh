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
	
        if [[ ! -z $bucket || ! -z $region ]]; then
            pwarning "No bucket location or region provided, please provision $CONFIG_FILE before publishing"
        fi

        cat >> $CONFIG_FILE <<CONF
---
region: $region
location: $bucket
---
CONF
    fi
}

function configure() {
    configure_social
    configure_upstream
}
