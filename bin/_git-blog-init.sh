function import_assets() {
    # Partial import, used for migration to update assets in-place
    if [ ! -z $1 ]; then
        # We don't want to clobber uncommitted local changes to assets
        break_on_staged_changes

        mv $STATIC_DIR/robots.txt $GIT_BASEDIR

        plog "Copying templates and static assets"
        rm -rf $TEMPLATE_DIR $STATIC_DIR
        rsync -a --exclude robots.txt $BINSRC/../new/static $BINSRC/../new/templates $GIT_BASEDIR

        plog "Restoring robots.txt"
        mv $GIT_BASEDIR/robots.txt $STATIC_DIR
    # Full import for new blog repos
    else
        plog "Copying initial resources"
        rsync -a $BINSRC/../new/ $GIT_BASEDIR
    fi
}

function initialize() {
    if [ -z $1 ]; then
        perror "Argument missing: must provide a name for the new blog"
        exit 1
    fi

    if [ ! $(is_aws_active) == 0 ]; then
        perror "Cannot create AWS assets, please login to AWS CLI"
        exit 1
    fi

    # Strip leading http[s] if provided
    domain=$(echo $1 | sed -r "s/https?:\/\///")

    if [ -e $domain ]; then
        perror "Directory with this name already exists"
        exit 1
    fi

    # Create new git-blog repo.
    mkdir $domain
    cd $domain
    git init

    # Reload constants now that we can resolve $GIT_BASEDIR
    source $BINSRC/_git-blog-constants.sh

    import_assets

    # Now that we know the repo name, add a rule in /robots.txt for the bundle.
    # NOTE: This should be static, it doesn't need to be re-created on build.
    if [ -e $STATIC_DIR/robots.txt ]; then
        plog "Disallow: /$domain.git" >> $STATIC_DIR/robots.txt
    fi

    psuccess "Created new blog repo $(pbold $GIT_BASEDIR)"

    plog "Configuring default title to $(pbold $domain)"
    write_config_attribute "title" $domain
    write_config_attribute "domain" $domain

    # Setup AWS S3 bucket to recieve published content, this does not include
    # configuring CloudFront or R53 to make the content publicly reachable.
    bucket=$domain
    region="us-east-1"

    plog "Configuring default bucket and region for AWS:"
    pbold "\tbucket: $bucket"
    pbold "\tregion: $region"

    write_config_attribute "bucket" $bucket
    write_config_attribute "region" $region

    plog "Creating S3 bucket."
    aws s3api create-bucket --bucket $bucket --region $region --object-ownership BucketOwnerPreferred 2>&1 > /dev/null
    aws s3api delete-public-access-block --bucket $bucket --region $region 2>&1 > /dev/null

    if [ $? -eq 0 ]; then
        psuccess "Created S3 bucket $(pbold $bucket) in $(pbold $region)"
    else
        perror "Could not create S3 bucket $(pbold $bucket), create bucket manually and run $(pbold git-blog configure upstream)"
    fi

    plog "Setting up social links for header navigation"

    configure_social

    git add . 2>&1 > /dev/null
    git commit -m "Initial commit of default assets." 2>&1 > /dev/null

    psuccess "Writing configuration to $(pbold $CONFIG_FILE)"
}
