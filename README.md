SRcomp Development Script
=========================

[![CircleCI](https://circleci.com/gh/PeterJCLaw/srcomp-dev.svg?style=shield)](https://circleci.com/gh/PeterJCLaw/srcomp-dev)

This repository contains a script - `init.sh` - which builds an srcomp
development environment by:

 * creating a virtualenv and configures it with external dependencies,
 * cloning and configuring the following repositories:
   * `ranker`, the game-points-to-league-points system;
   * `srcomp`, the core srcomp library;
   * `srcomp-http`, the srcomp REST API;
   * `srcomp-scorer`, the srcomp score entry system,
   * `srcomp-screens`, the repository containing the arena display HTML,
   * `srcomp-stream`, the system that streams events live,
   * `dummy-comp`, the standard testing compstate repository

It then emits instructions on how to use the virtualenv.

While other compstates can be used, basic usage is: `python run.py dummy-comp`

The HTTP API is exposed via <http://localhost:5112/comp-api/>, while the
screen pages are at:

 * <http://localhost:5112/arena.html>
 * <http://localhost:5112/outside.html>
 * <http://localhost:5112/shepherding.html>
 * <http://localhost:5112/staging.html>

The stream is exposed as <http://localhost:5001/> and the scorer is at
<http://localhost:5112/scorer>.

Bootstrap dependencies
----------------------

In order to run `init.sh` you'll need:

 * git
 * Python 2 or 3
 * Virtualenv
 * NPM
 * Bower (will be installed from NPM if missing)


Updating dependencies
---------------------

Dependencies can be updated by using `pip-compile`, though note that care must
be taken to ensure that the resulting dependencies are compatible with the
various SRComp projects which this repo configures. This is unfortunately not
currently checked by running `pip-compile`.
