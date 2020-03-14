#!/bin/bash
function clone_repo {
    if [ -d "$1" ]; then
        echo 'Skipped: already exists.'
    else
        git clone --recursive git://github.com/PeterJCLaw/$1
    fi
}

for POSSIBLE_PYTHON in python python3;
do
    PYTHON=$(which $POSSIBLE_PYTHON)
    $PYTHON --version 2>&1 | grep -E 'Python (3\.)' >/dev/null
    if [ $? -eq 0 ]; then
        echo "Found Python: $PYTHON"
        break
    else
        PYTHON=
    fi
done
if [ -z "$PYTHON" ]; then
    echo "No suitable Python installation found."
    exit 1
fi

if [ -f /etc/lsb-release ]; then
    if grep 'Ubuntu 14\.04' /etc/lsb-release; then
        DODGY_UBUNTU=1
    fi
fi

# Check that bower is installed
bower --version
if [ $? -ne 0 ]; then
    npm --version
    if [ $? -ne 0 ]; then
        echo "npm not installed. Install it through your system package manager."
        exit 1
    fi
    echo "Bower not installed. Please install it:"
    echo "$ npm install -g bower"
    exit 1
fi

set -e
if [ -n "$DODGY_UBUNTU" ]; then
    echo "Using /usr/bin/virtualenv due to Ubuntu 14.04's broken Python 3.4"
    /usr/bin/virtualenv -p "$PYTHON" venv
else
    "$PYTHON" -m venv venv
fi
source venv/bin/activate
set -v
pip install -r requirements.txt
clone_repo ranker
clone_repo srcomp
clone_repo srcomp-http
clone_repo srcomp-screens
clone_repo dummy-comp
clone_repo srcomp-scorer
clone_repo srcomp-cli
clone_repo srcomp-stream
clone_repo srcomp-kiosk
clone_repo srcomp-puppet
cd ranker
    pip install -e .
cd ..
cd srcomp
    pip install -e .
cd ..
cd srcomp-http
    pip install -e .
cd ..
cd srcomp-scorer
    pip install -e .
cd ..
cd srcomp-cli
    pip install -e .
cd ..
cd srcomp-screens
    bower install
cd ..
cd srcomp-stream
    sed 's_SRCOMP: .*_SRCOMP: "http://localhost:5112/comp-api"_' <config.local.coffee.example >config.local.coffee
    npm install
cd ..
set +v
echo "-- DONE SETUP --"
echo "Usage: "
echo "  (1) Activate the virtualenv: source venv/bin/activate"
echo "  (2) Run everything with run.py"
