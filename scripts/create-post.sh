#!/bin/sh

# Usage: scripts/create-post.sh $name
# Create a new post.

set -e
set -o nounset
set -o pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: scripts/create-post.sh <name>"
    exit
fi

BLOG_ROOT=$(dirname "${BASH_SOURCE}")/..

# Create a header with date command.
template="
title: \"{title}\"\n\
date: atime\n\
update: ctime\n\
author: {author}\n\
cover: \"{cover(optional)}\"\n\
tags:\n\
    - {tag}\n\
preview: {preview(optional)}\n\n\
---\n
"
realTime=$(date "+%Y-%m-%d %H:%M:%S")
templateWithoutDate="${template/atime/$realTime}"
header="${templateWithoutDate/ctime/$realTime}"

cd ${BLOG_ROOT}/source
if [ ! -f ${1}.md ]; then
	# The file doesn't exist, so create a new file
	# and add header to it.
    touch ${1}.md
    echo $header > ${1}.md
else
	# The file exists, exit.
    echo "${1}.md exists."
    exit
fi
cd - > /dev/null
