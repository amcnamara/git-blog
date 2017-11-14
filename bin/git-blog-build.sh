function build() {
    cd_base

    PUBLIC_DIR=$PWD/public
    TEMPLATE_DIR=./templates
    CONTENT_DIR=./content

    rm -rf $PUBLIC_DIR

    rsync -a ./static/* ./public

    for post in $(find $CONTENT_DIR -name "*.md"); do
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
}
