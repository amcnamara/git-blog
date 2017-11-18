function build() {
    rm -rf $PUBLIC_DIR
    rsync -a $STATIC_DIR/* $PUBLIC_DIR

    # Find all markdown posts
    content=`find $CONTENT_DIR -name "*.md"`

    if [[ ! ${content[@]} ]]; then
	echo "No content found to build, use \`${YELLOW}git-blog add${NOCOLOUR}\` to create some!"
	exit 1
    fi

    # Order posts by creation time, useful for rss and index pages
    content=`ls -tU $content`

    # Render all content
    for post in $content; do
        # Find the template and corresponding output path for the given post

	midpath=`dirname $post`
	# NOTE: Trim off parent directories from content/ upward, and leading /
	midpath=${midpath:${#CONTENT_DIR}+1}

	template=$TEMPLATE_DIR/$midpath/template.mustache
        output=$PUBLIC_DIR/$midpath/$(basename $post | cut -d. -f1 -).html

	# Ensure that the template exists for the given post
        if [ ! -e $template ]; then
            pwarning "Cannot render post, skipping due to missing template:"
            echo "         post '$post'"
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
---
$(for key in $(multimarkdown -m $post); do
  echo $key: $(multimarkdown -e=$key $post)
done)
content: '$(multimarkdown --snippet $post)'
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
