#!/bin/bash
function clone_repo {
    if [ -d "$1" ]; then
        echo 'Skipped: already exists.'
    else
        git clone --recursive https://github.com/${2:-PeterJCLaw}/$1
    fi
}

for POSSIBLE_PYTHON in python3.12 python3.11 python3.10 python3.9 python3.8 python3 python;
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

# Check that yarn is installed
yarn --version
if [ $? -ne 0 ]; then
    npm --version
    if [ $? -ne 0 ]; then
        echo "npm not installed. Install it through your system package manager."
        exit 1
    fi
    echo "yarn not installed. Please install it:"
    echo "$ npm install -g yarn"
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
pip install -U setuptools pip
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
clone_repo livestream-overlay srobo
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
    yarn install
    python -c '
import sys, json
print(json.dumps({
    **json.load(sys.stdin),
    "apiurl": "http://localhost:5112/comp-api",
    "streamurl": "http://localhost:5001/"
}, indent=2))' <config.example.json >config.json
cd ..
cd srcomp-stream
    sed 's_SRCOMP: .*_SRCOMP: "http://localhost:5112/comp-api"_' <config.local.coffee.example >config.local.coffee
    npm install
cd ..
cd livestream-overlay
    npm install
    npm run build
    sed 's_streamServerURI.*_streamServerURI = "http://localhost:5001/";_;
        s_apiURI.*_apiURI = "http://localhost:5112/";_' settings.example.js >settings.js
cd ..
set +v
echo "-- DONE SETUP --"
echo "Usage: "
echo "  (1) Activate the virtualenv: source venv/bin/activate"
echo "  (2) Run everything with run.py"
