function add() {
    cd_base

    POST_DIR=$PWD/content/posts
    NOW=$(date +"%m%d%Y%H%M")

    # TODO: Point /index.html to this post? Should this be done in R53?
    cat <<POST > $POST_DIR/${NOW}_$1.md
title: "$(tr '_' ' ' <<< $(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1})"
description: ""

<!-- post content starts here -->
POST

    echo "Writing $POST_DIR/${NOW}_$1.md"
}
