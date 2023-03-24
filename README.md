Installation
------------

To configure your local environment, validate dependencies and install git-blog; simply run:
```
./configure
make
make install
```

Usage
-----

| | |
| - | - |
| `git-blog init <name>`      | Creates a new local blog repo, with some default assets.
| `git-blog clone <target>`   | Creates a local copy of an existing published blog.
| `git-blog configure`        | Configures global metadata (social handles, AWS credentials, etc) on an existing blog repo.
| `git-blog write <title>`    | Creates a new blog post.
| `git-blog build`            | Builds all static assets into public.
| `git-blog publish`          | Copies static assets to target S3 bucket.
| | |