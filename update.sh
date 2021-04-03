#!/bin/bash
for repo in dummy-comp sr2014-comp sr2015-comp sr2016-comp ranker srcomp srcomp-http srcomp-scorer srcomp-screens srcomp-stream srcomp-cli srcomp-kiosk livestream-overlay; do
    echo $repo
    echo ------------------
    pushd $repo && \
        git pull --ff-only
    popd
    echo
done

echo srcomp-dev
echo ------------------
git pull --ff-only
