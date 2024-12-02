function publish() {
    # Ensure that all local changes have been committed
    if [[ $(git status --porcelain) ]]; then
        perror "Cannot publish, you have uncommited local changes"
        exit 1
    fi

    # TODO: Write a publish datestamp into any posts which don't already
    #       have one, this will be rendered both on the post markup as
    #       well as the RSS feed as the file creation time isn't as
    #       meaningful especially if a post takes a long time to write.
    # TODO: Have a flag for draft posts which will not get datestamps,
    #       and which are not rendered on build but are in the bundle.
    pwarning "Publish datestamps are not yet implemented"

    # Fire off a build
    build

    # TODO: Upload ./public to S3 and CF.
    pwarning "Pushing to S3 is not yet implemented"
}
