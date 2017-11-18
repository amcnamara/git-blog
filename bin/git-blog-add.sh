function add() {
    cat <<POST > $POST_DIR/$1.md
title: "$(tr '_' ' ' <<< $(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1})"
description: ""

<!-- post content starts here -->
POST

    pbold "Writing ${GRAY}$POST_DIR/$1.md${NOCOLOUR}"
}
