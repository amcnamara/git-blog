function write() {
    if [ -z $1 ]; then
        perror "Argument missing: must provide a post title"
        exit 1
    fi

    # Create content directory if it doesn't exist (git can't hold an empty dir
    # in the `new` default directory)
    mkdir -p $POST_DIR

    filename="${@}"         # Pull all args as the filename
    filename="${filename// /_}" # Replace whitespace with underscores
    filename="${filename,,}"    # Make all lowercase

    # NOTE: We need to prepend a datestamp to the file in order to sort
    #       posts by creation time, since this file metadata is lost on
    #       cloned repositories.
    filename="$POST_DIR/`date '+%Y_%m_%d'`_$filename.md"

    # This is exceedingly unlikely now that filenames have a creation timestamp.
    if [ -e $filename ]; then
        perror "A post with this name already exsits"
        exit 1
    fi

    cat <<POST > $filename
title: ${@}
keywords:
description:
-----------
POST

    pbold "Writing $filename"

    # Try to find a default editor, open the new file.
    # NOTE: It's necessary to plumb through std in and out from the subshell
    #       otherwise vi will be orphoned from the terminal.
    $(${EDITOR:-vi} $filename < $(tty) > $(tty))
}
