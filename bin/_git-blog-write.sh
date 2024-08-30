function write() {
    datestamp=$(date '+%b %d, %Y')
    timestamp=$(date '+%l:%M %p')
    timestamp=${timestamp#\ } # Trim leading space if hour has a single digit.

    # Create content directory if it doesn't exist (git can't hold an empty dir
    # in the `new` default directory)
    mkdir -p $POST_DIR

    # NOTE: We need to prepend a datestamp to the file in order to sort
    #       posts by creation time, since this file metadata is lost on
    #       cloned repositories.
    filename="$POST_DIR/`date '+%Y_%m_%d'`_$1.md"

    # This is exceedingly unlikely now that filenames have a creation timestamp.
    if [ -e $filename ]; then
        perror "A post with this name already exsits"
        exit 1
    fi

    # Generate a friendly title from the filename:
    # - Capitalize the first character of the filename
    # - Append the remaining characters of the filename
    # - Convert underscores to spaces
    title=`tr '[:lower:]' '[:upper:]' <<< ${1:0:1}`
    title=$title${1:1}
    title=`tr '_' ' ' <<< $title`

    cat <<POST > $filename
title: $title
timestamp: $timestamp
datestamp: $datestamp
keywords:
description:

<!-- post content starts below here -->
POST

    pbold "Writing $filename"

    # Try to find a default editor, open the new file.
    # NOTE: It's necessary to plumb through std in and out from the subshell
    #       otherwise vi will be orphoned from the terminal.
    $(${EDITOR:-vi} $filename < $(tty) > $(tty))
}
