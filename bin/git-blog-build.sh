function build() {
    FILE=test.md
    TEMPLATE=./templates/index.mustache
    
    cat <<METADATA | mustache - $TEMPLATE >> output.html
--- 
$(for key in $(multimarkdown -m $FILE); do
  echo $  key: $(multimarkdown -e=$key $FILE)
done)  
---    
METADATA

    pwd
}
