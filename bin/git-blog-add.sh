function add() {
    if [ -e $POST_DIR/$1.md ]; then
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

    cat <<POST > $POST_DIR/$1.md
title: "$title"
description: ""

<!-- post content starts here -->
POST

    pbold "Writing $POST_DIR/$1.md"

    # Try to find a default editor, open the new file.
    # NOTE: It's necessary to plumb through std in and out from the subshell
    #       otherwise vi will be orphoned from the terminal.
    `${EDITOR:-vi} $POST_DIR/$1.md < $(tty) > $(tty)`
}
