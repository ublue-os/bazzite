#!/bin/sh

proto=$1
branch=$2

if [ -z "$proto" ]; then
    echo "Usage: $0 <proto name> [<branch>]"
    exit 1
fi

dirname=$proto-$( date +%Y%m%d )

rm -rf $dirname
git clone git://git.freedesktop.org/git/xorg/proto/$proto $dirname
cd $dirname
if [ -z "$branch" ]; then
    git log | head -1
else
    git checkout $branch
fi
sha=`git rev-list --max-count=1 --abbrev-commit HEAD`
git repack -a -d
cd ..

# append sha to dirname
mv $dirname $dirname-git$sha
dirname=$dirname-git$sha
tarball=$dirname.tar.bz2
tar jcf $tarball $dirname
rm -rf $dirname
echo "$tarball is now available"
