todo:
- create bin that prefixes title folder with datetimestamp
- parse markdown into html and json blobs
- html should contain header, footer, inline stylesheet
- header should contain menu with navigation, this should be generated to match content of available posts
- dev environment should have webserver to host build/ dir
- create bin that pushes all content to s3, updates index for domain to newest post (or overview?)
- post abstracts should be in folder/abstract, post in folder/body
- is markdown the best solution here?

## Setup

You'll need node and http-server for local testing of built assets. The script bin/cfb-init will attempt to install local dependencies, as well as configure AWS access keys for publishing content. Go, run it now.

## Usage