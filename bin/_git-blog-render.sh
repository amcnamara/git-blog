# Pre-rendering is an optional step during build, it allows the page to
# be fully rendered, then edited, and snapshotted back to a static page.
# This can be helpful to have some scripts run a pass on the page, such
# as for syntax hilighting in code blocks.
#
# NOTE: For a pre-render to be applied during build, add a tag for
#       'build-opts: pre-render' to the post metadata block.
# NOTE: Any element with the class '.git-blog-prerender-destroy' will be
#       removed from the generated asset.
# NOTE: Any element with the class '.git-blog-prerender-clear' will have
#       its children removed from the generated asset (this is helpful
#       to ensure the background vector container remains empty).
function pre_render() {
    local global_node_path=""
    if is_command "npm"; then
        global_node_path=$(npm root -g 2> /dev/null)
    fi

    local node_path="${NODE_PATH}"
    if [ -n "$global_node_path" ]; then
        if [ -n "$node_path" ]; then
            if [[ ":$node_path:" != *":$global_node_path:"* ]]; then
                node_path="$node_path:$global_node_path"
            fi
        else
            node_path="$global_node_path"
        fi
    fi

    NODE_PATH="$node_path" node <<SCRIPT
const fs = require("fs");
const puppeteer = require("puppeteer");

(async () => {
  const browser = await puppeteer.launch();
  
  const page = await browser.newPage();

  // Read the input HTML file
  const htmlContent = fs.readFileSync("$1", "utf8");

  // Set the content
  await page.setContent(htmlContent, { waitUntil: "domcontentloaded" });

  // Remove or clear elements as needed
  await page.evaluate(() => {
    document.querySelectorAll('.git-blog-prerender-delete').forEach(element => {element.remove()});
    document.querySelectorAll('.git-blog-prerender-clear').forEach(element => {element.innerHTML=""});
  });

  // Extract the updated HTML
  const updatedHTML = await page.content();

  // Write to the output file
  fs.writeFileSync("$1", updatedHTML);

  console.log("Pre-render pass complete, saving snapshot to: $1");

  await browser.close();
})();
SCRIPT
}
