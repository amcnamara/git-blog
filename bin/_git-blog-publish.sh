function publish() {
    # Ensure that all local changes have been committed
    if [[ $(git status --porcelain) ]]; then
	perror "Cannot publish, you have uncommited local changes"
	exit 1
    fi

    # Fire off a build
    # TODO: Find a better way to determine if a build has already been run and
    #       the assets exist under public. Perhaps fingerprint with commit ID?
    build

    # TODO: Upload public to S3 and CF.
    pwarning "Pushing to S3 is not yet implemented"
}
