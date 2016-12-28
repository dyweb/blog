# Contribution Guidelines

## DO NOT

- edit generated file (in `docs` folder) directly

## Workflow

- `create-post` means the python script `scripts/create-post`, run it using its name (`./scripts/create-post`).

### Create new branch

- create a branch `post/your-post-title`. i.e. `git checkout -b post/all-about-ayi`.
- NOTE: you don't need another branch if you are not included in `config.yml` as an author, just put them in one PR.

### Create author

The `create-post` can update the `config.yml` and create `about.author_name.md` for you and
fill it will your github info if possible, you can update it after running `create_post`.
If you do it manually before run the script, remember to do the both

- add block in `config.yaml` in the `authors` block, don't remove the `#MAGIC` comment
- create `about.author_name.md`

### Create post

Use `scripts/create-post` to create the md file

````bash
# create a post as gaocegege and using english template, NOTE: if your title has space, wrap them with quote
./script/create-post "How to setup a rust server" -a gaocegege -l en
````
- update the generated meta data
- run `ink preview` to have preview when editing the post
- run `scripts/pre-deploy` before commit to build and move to `docs` folder
- write commit message using the following format `[post] your post title`
- push the new branch and create a pull request
- wait for review
- merge to master and publish
