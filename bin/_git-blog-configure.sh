function configure_social() {
    # Configure social handles
    read -e -p "Please enter your github handle (or leave blank): " -i "$(echo_config_attribute 'github')" github 2>&1
    write_config_attribute "github" $github

    read -e -p "Please enter your linkedin handle (or leave blank): " -i "$(echo_config_attribute 'linkedin')" linkedin 2>&1
    write_config_attribute "linkedin" $linkedin

    read -e -p "Please enter your bluesky handle (or leave blank): " -i "$(echo_config_attribute 'bluesky')" bluesky 2>&1
    write_config_attribute "bluesky" $bluesky

    read -e -p "Please enter your twitter handle (or leave blank): " -i "$(echo_config_attribute 'twitter')" twitter 2>&1
    write_config_attribute "twitter" $twitter

    read -e -p "Please enter your facebook handle (or leave blank): " -i "$(echo_config_attribute 'facebook')" facebook 2>&1
    write_config_attribute "facebook" $facebook

    read -e -p "Please enter your email address (or leave blank): " -i "$(echo_config_attribute 'email')" email 2>&1
    write_config_attribute "email" $email
}

function configure_domain() {
    read -e -p "Please enter the domain (including http[s]://) where your blog is hosted: " -i "$(echo_config_attribute 'domain')" domain 2>&1
    write_config_attribute "domain" $domain
}

function configure_upstream() {
    # Configure blog hosting metadata
    read -e -p "Please enter the AWS region where your blog is hosted: " -i "$(echo_config_attribute 'region')" region 2>&1
    write_config_attribute "region" $region

    read -e -p "Please enter the ARN of the S3 bucket where your blog is hosted: " -i "$(echo_config_attribute 'bucket')" bucket 2>&1
    write_config_attribute "bucket" $bucket

    if [[ -z $bucket || -z $region ]]; then
        pwarning "No bucket location or region provided, please provision before publishing"
    fi
}

function configure() {
    case $1 in
        social)
            configure_social
            ;;
        domain)
            configure_domain
            ;;
        upstream)
            configure_upstream
            ;;
        *)
            configure_social
            configure_domain
            configure_upstream
            ;;
    esac

    psuccess "Writing configuration to ${WHITE}$CONFIG_FILE${NOCOLOUR}"
}
