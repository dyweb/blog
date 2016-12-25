# Contribution Guidelines

## DO NOT

- edit generated file (in `docs` folder) directly

## Workflow

- create a branch `post/your-post-title`. i.e. `git checkout -b post/all-about-ayi`.
- add yourself to `config.yml` in `authors` block if you are not presented
- use `scripts/create-post` to create the md file
- update the generated meta data
- run `ink preview` to have preview when editing the post
- run `scripts/pre-depoly` before commit to build and move to `docs` folder
- write commit message using the following format `[post] your post title`
- push the new branch and create a pull request
- wait for review
- merge to master and publish
