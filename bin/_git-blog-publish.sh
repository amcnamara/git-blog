function publish() {
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

    pwarning "Publish datestamps are not yet implemented"

    # Fire off a clean build
    build

    # TODO: Upload ./public to S3 and CF.
    pwarning "Pushing to S3 is not yet implemented"
}
