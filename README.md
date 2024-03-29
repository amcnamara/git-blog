Description
-----------

`Git-blog` is a locally-run content publishing workflow with a few broad goals:
- Content should be portable (can be pulled, written, and published from a fresh machine easily).
- Content should be entirely static and CDN-hosted (very fast and serverless).
- Content should be deeply archivable.

That last point is probably the most interesting. What I mean by deeply archivable is that the full history of all published content should be published alongside the content itself; even down to iterations on content, HTML/JS templating, and CSS. In practice this means that all of the content is version-controlled through Git and a bundle is pushed into the CDN with each new post. The bundle can be used to pull down the full history at any point, and by resetting locally a facsimile of content can be rebuilt for any commit in the past. The web has become disappointinly ephemeral over time and while the [Internet Archive](https://archive.org/) is an incredible resource I wanted to see if other approaches could be used to achive more permanence online.

You're welcome to use and improve this tool if you like but [GitHub pages](https://pages.github.com/) with [Jekyll](https://jekyllrb.com/) accomplishes almost all of the main goals of this project, and is a better tool in general.

Installation
------------

To run this project, the following dependencies need to be installed:
- https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
- https://fletcher.github.io/MultiMarkdown-5/installation
- http://www.html-tidy.org/#homepage19700601get_tidy
- https://github.com/tests-always-included/mo
- https://www.python.org/downloads
- http://docs.aws.amazon.com/cli/latest/userguide/installing.html

Run the following to validate dependencies and install `git-blog`:
```
make all
```

For reference, my development machine is running the following:
- 2019 Macbook Pro (Intel x86) with MacOS 13.2.1
- Bash v5.2.15
- Git v2.40.0
- Mo v2.2.0
- Tidy build 8765
- MultiMarkdown v6.6.0
- Python 3.11.2
- AWS CLI v2.11.5

Usage
-----
```
git-blog --help
```

Getting Started
---------------

1) Sign into the AWS CLI
2) Start by initializing a new blog: `git-blog init example.com` bootstraps a new git repo with some default assets, creates an upstream S3 bucket to publish to, and sets some project config attributes.
3) Create a new post: `git-blog write hello_world` will create an empty post in `content/posts` with some markdown metadata, fill in the body of the post and save.
4) Review content: `git-blog build` and then open `http://localhost:8080` in a browser to navigate the built assets.
5) Publish content: `git-blog publish` will build assets and push to S3, if you have CloudFront configured for that bucket the assets should appear after the previous CDN entries expire.
6) It's a good idea to backup the blog's repo by pushing to a second upstream source such as Github.
