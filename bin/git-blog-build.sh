function build() {
    cd_base

    echo $PUBLIC_DIR

    rm -rf $PUBLIC_DIR
    rsync -a ./static/* ./public

    # Get all markdown content files ordered by creation time
    content=$(ls -tU $(find $CONTENT_DIR -name "*.md"))

    # Render all content
    for post in $content; do
        # Find the template and corresponding output path for the given post
        midpath=$(dirname $post | cut -d/ -f3- -)
        template=$TEMPLATE_DIR/$midpath/template.mustache
        output=$PUBLIC_DIR/$midpath/$(basename $post | cut -d. -f1 -).html

	# Ensure that the template exists for the given post
        if [ ! -e $template ]; then
            echo "WARNING: Cannot render post, skipping due to missing template:"
            echo "         post '$post'"
            echo "         expected template '$template'"
            continue
        fi

        # Ensure that public directory and midpath subdirectories exist
        if [ ! -e ./$PUBLIC_DIR/$midpath ]; then
            mkdir -p $PUBLIC_DIR/$midpath
        fi

        echo "Writing $output"

        # TODO: Consider adding support for http://www.html-tidy.org/ on output
        cat <<METADATA | cat ./config.yaml - | mustache - $template >> $output
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
	echo "WARNING: Index generation not yet implemented."
    fi

    if is_config_attribute "sitemap"; then
	echo "WARNING: Sitemap generation not yet implemented."
    fi

    if is_config_attribute "rss"; then
	echo "WARNING: RSS generation not yet implemented."
    fi

    if is_config_attribute "bundle"; then
	name="$PUBLIC_DIR/$(basename $PWD).git"
	git bundle create $name --all
	echo "Generated git bundle: $name"
    fi

    # TODO: Use gzip to compress assets? Need to set content-encoding on the S3 bucket/files(?)
}
