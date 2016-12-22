#!/bin/sh

# Usage: scripts/pre-deploy.sh
# Build a new version of blog.

set -e
set -o nounset
set -o pipefail

BLOG_ROOT=$(dirname "${BASH_SOURCE}")/..

cd ${BLOG_ROOT}
rm -rf public
rm -rf docs
ink build
mv public docs
echo "Finished to rename public folder."
cd - > /dev/null
