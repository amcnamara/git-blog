function build() {
    rm -rf $PUBLIC_DIR
    rsync -a $STATIC_DIR/* $PUBLIC_DIR

    # Find all markdown content (including siblings of the posts directory)
    content=`find $CONTENT_DIR -name "*.md"`

    if [[ ! ${content[@]} ]]; then
        echo "No content found to build, use \`${YELLOW}git-blog write <post_title>${NOCOLOUR}\` to create some!"
        exit 1
    fi

    # NOTE: Separately from \$content, which may include other documents,
    #       find all posts and order them alphabetically. Generated posts
    #       have their creation time prepended to the filename since the
    #       file metadata is lost during cloning. Chronological ordering
    #       here is particularly important for building the index, RSS, etc.
    posts=`find $POST_DIR -name "*.md"`
    posts=`ls $posts`

    echo "Generating index of post metadata"

    # Generate a YAML list containing all post metadata. This will be plumbed
    # through all of the content templates, the index, and RSS feed.
    #
    # NOTE: String expression below is necessary to properly escape newlines.
    index=$'---\nindex:'

    for post in $posts; do
	index+="
  - title: $(multimarkdown -e=title $post)
    timestamp: $(multimarkdown -e=timestamp $post)
    datestamp: $(multimarkdown -e=datestamp $post)
    description: $(multimarkdown -e=description $post)"
    done

    index+=$'\n---'

    # Render all content
    for document in $content; do
        # Find the template and corresponding output path for the given document

        midpath=`dirname $document`
        # NOTE: Trim off parent directories from content/ upward, and leading /
        midpath=${midpath:${#CONTENT_DIR}+1}

        template=$TEMPLATE_DIR/$midpath/template.mustache
        output=$PUBLIC_DIR/$midpath/$(basename $document | cut -d. -f1 -).html

        # Ensure that the template exists for the given document
        if [ ! -e $template ]; then
            pwarning "Cannot render document, skipping due to missing template:"
            echo "         document '$document'"
            echo "         expected template '$template'"
            continue
        fi

        # Ensure that public directory and midpath subdirectories exist
        if [ ! -e $PUBLIC_DIR/$midpath ]; then
            mkdir -p $PUBLIC_DIR/$midpath
        fi

        pbold "Writing $output"

        # TODO: Consider adding support for http://www.html-tidy.org/ on output
        cat <<METADATA | cat $CONFIG_FILE - | mustache - $template >> $output
$index
---
$(for key in $(multimarkdown -m $document); do
  echo $key: $(multimarkdown -e=$key $document)
done)
content: '$(multimarkdown --snippet $document)'
---
METADATA
    done

    # Build options (all are recommended and enabled by default in new projects, see README):
    # - Index content, ordered by creation time
    # - Sitemap of content links
    # - Generate RSS feed of content, ordered by creation time
    # - Generate Git bundle asset

    if is_config_attribute "index"; then
        pwarning "Index generation not yet implemented."
    fi

    if is_config_attribute "sitemap"; then
        pwarning "Sitemap generation not yet implemented."
    fi

    if is_config_attribute "rss"; then
        pwarning "RSS generation not yet implemented."
    fi

    if is_config_attribute "bundle"; then
        name="$PUBLIC_DIR/$(basename $GIT_BASEDIR).git"
        if git bundle create $name --all; then
            psuccess "Generated git bundle: $name"
        else
            perror "Could not create git bundle"
        fi
    fi

    # TODO: Use gzip to compress assets? Need to set content-encoding on the S3 bucket/files(?)
}
