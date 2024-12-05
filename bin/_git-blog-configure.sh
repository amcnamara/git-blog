function configure_social() {
    # Configure social handles
    read -e -p "Please enter your github handle (or leave blank): " -i "$(echo_config_attribute 'github')" github 2>&1
    write_config_attribute "github" $github

    read -e -p "Please enter your bluesky handle (or leave blank): " -i "$(echo_config_attribute 'bluesky')" bluesky 2>&1
    write_config_attribute "bluesky" $bluesky

    read -e -p "Please enter your twitter handle (or leave blank): " -i "$(echo_config_attribute 'twitter')" twitter 2>&1
    write_config_attribute "twitter" $twitter

    read -e -p "Please enter your facebook handle (or leave blank): " -i "$(echo_config_attribute 'facebook')" facebook 2>&1
    write_config_attribute "facebook" $facebook
}

function configure_title() {
    read -e -p "Please enter the title for your blog: " -i "$(echo_config_attribute 'title')" title 2>&1
    write_config_attribute "title" $title
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
    # If no flags provided, run all config options
    if [ $# -eq 0 ]; then
        social=true
        title=true
        upstream=true
    else
        # Otherwise, pull out individual flags
        while [[ $# -gt 0 ]]; do
            case $1 in
                -s|--social)
                    social=true
                    shift
                    ;;
                -t|--title)
                    title=true
                    shift
                    ;;
                -u|--upstream)
                    upstream=true
                    shift
                    ;;
                *|-*|--*)
                    perror "Unknown option: $1"
                    exit 1
                    ;;
            esac
        done
    fi

    if [ "$social" = true ]; then
        configure_social
    fi

    if [ "$title" = true ]; then
        configure_title
    fi

    if [ "$upstream" = true ]; then
        configure_upstream
    fi

    psuccess "Writing configuration to ${WHITE}$CONFIG_FILE${NOCOLOUR}"
}
