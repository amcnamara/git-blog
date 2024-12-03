function publish() {
    # Check whether the AWS CLI is logged in, don't echo credential.
    aws sts get-caller-identity &> /dev/null
    if [ ! $? == 0 ]; then
        perror "Cannot publish, please log into the AWS CLI"
        exit 1
    fi

    bucket=$(echo_config_attribute "bucket")
    if [ -z $bucket ]; then
        plog "S3 bucket is not defined, please run 'git-blog configure aws'"
        exit 1
    fi

    region=$(echo_config_attribute "region")
    if [ -z $region ]; then
        plog "S3 region is not defined, please run 'git-blog configure upstream'"
        exit 1
    fi

    # Ensure that all local changes have been committed
    if [[ $(git status --porcelain) ]]; then
        perror "Cannot publish, you have uncommited local changes"
        exit 1
    fi

    # Write a publish datetime into any posts which don't already
    # have one.  This will be rendered both on the post markup as
    # well as the RSS feed as the file creation time isn't as
    # meaningful especially if a post takes a long time to write.
    #
    # TODO: Have a flag for draft posts which will not get datestamps,
    #       and which are not rendered on build but are in the bundle.
    for post in `echo $(find $POST_DIR -name "*.md")`; do
        if [[ ! $(head -n 1 $post) =~ "publish_date:" ]]; then
            plog "Injecting publish datestamp into $post"
            echo -e "publish_date: $(date -R)\n$(cat $post)" > $post
        fi
    done

    git add $GIT_BASEDIR/content/posts
    git commit -m "[git-blog publish] Injecting content timestamp."

    # Fire off a clean build to pick up publish datestamps
    plog "Generating a clean build"
    build

    # Clear existing S3 resources
    plog "Deleting existing upstream content"
    aws s3 rm s3://$bucket --region $region --recursive

    if [ $? == 0 ]; then
        psuccess "S3 bucket $bucket in region $region has been cleared"
    else
        perror "S3 bucket clear failed, you may need to recover the bucket's previous contents."
        pbold "\tbucket: $bucket"
        pbold "\tregion: $region"
        exit 1
    fi

    plog "Uploading new build assets to $bucket in $region"
    aws s3 cp $PUBLIC_DIR/. s3://$bucket/ --recursive --acl public-read

    if [ $? == 0 ]; then
        psuccess "S3 assets have been uploaded to $bucket in $region"
    else
        perror "S3 bucket upload failed, you may need to recover the bucket's previous contents."
        pbold "\tbucket: $bucket"
        pbold "\tregion: $region"
        exit 1
    fi
}
