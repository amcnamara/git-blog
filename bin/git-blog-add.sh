function add() {
    if [ -e $POST_DIR/$1.md ]; then
	perror "A post with this name already exsits"
	exit 1
    fi

    cat <<POST > $POST_DIR/$1.md
title: "$(tr '_' ' ' <<< $(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1})"
description: ""

<!-- post content starts here -->
POST

    pbold "Writing $POST_DIR/$1.md"

    # Try to find a default editor. Plumb the std in and out from the
    # subshell to the editor (which is particularly important for vi).
    `${EDITOR:=vi} $POST_DIR/$1.md < $(tty) > $(tty)`
}
