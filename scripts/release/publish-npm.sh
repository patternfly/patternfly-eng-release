#!/bin/sh

default()
{
  # Add paths to env (non-Travis build)
  if [ -z "$TRAVIS" ]; then
    PATH=/bin:/usr/bin:/usr/local/bin:$PATH
    export PATH
  fi

  SCRIPT=`basename $0`
  SCRIPT_DIR=`dirname $0`
  SCRIPT_DIR=`cd $SCRIPT_DIR; pwd`

  . $SCRIPT_DIR/../_env.sh
  . $SCRIPT_DIR/../_common.sh
  . $SCRIPT_DIR/_common.sh

  BRANCH=$RELEASE_DIST_BRANCH
  TMP_DIR="/tmp/patternfly-releases"
}

# Publish to npm
#
publish_npm()
{
  echo "*** Publishing npm"
  cd $BUILD_DIR

  # Log into npm
  if [ -n "$NPM_USER" -a -n "$NPM_PWD" ]; then
    printf "$NPM_USER\n$NPM_PWD\n$NPM_USER@redhat.com" | npm login
    check $? "npm login failure"
  fi

  # Tag dev release: https://medium.com/@mbostock/prereleases-and-npm-e778fc5e2420#.s6a099w69
  if [ -n "$TAG_DEV" ]; then
    npm publish -tag next
  else
    npm publish
  fi
  check $? "npm publish failure"
}

usage()
{
cat <<- EEOOFF

    This script will npm publish from the latest repo clone or Travis build.

    sh [-x] $SCRIPT [-h|b|d|s] -a|e|p|w

    Example: sh $SCRIPT -p

    OPTIONS:
    h       Display this message (default)
    a       Angular PatternFly
    e       Patternfly Eng Release
    p       PatternFly
    w       Patternfly Web Components

    SPECIAL OPTIONS:
    b       The branch to publish (e.g., branch-4.0-dev)
    d       Release dev branches (e.g., PF4 alpha, beta, etc.)
    s       Skip new clone (e.g., to rebuild repo)

EEOOFF
}

# main()
{
  default

  if [ "$#" -eq 0 ]; then
    usage
    exit 1
  fi

  while getopts hab:depsw c; do
    case $c in
      h) usage; exit 0;;
      a) BUILD_DIR=$TMP_DIR/angular-patternfly;
         REPO_SLUG=$REPO_SLUG_PTNFLY_ANGULAR;;
      b) BRANCH=$OPTARG;;
      d) TAG_DEV=1;;
      e) BUILD_DIR=$TMP_DIR/patternfly-eng-release;
         REPO_SLUG=$REPO_SLUG_PTNFLY_ENG_RELEASE;;
      p) BUILD_DIR=$TMP_DIR/patternfly;
         REPO_SLUG=$REPO_SLUG_PTNFLY;;
      s) SKIP_SETUP=1;;
      w) BUILD_DIR=$TMP_DIR/patternfly-webcomponents;
         REPO_SLUG=$REPO_SLUG_PTNFLY_WC;;
      \?) usage; exit 1;;
    esac
  done

  # Publish from the latest repo clone or Travis build
  if [ -n "$TRAVIS_BUILD_DIR" ]; then
    BUILD_DIR=$TRAVIS_BUILD_DIR
  fi
  if [ -z "$SKIP_SETUP" ]; then
    setup_repo $REPO_SLUG $BRANCH
  fi

  publish_npm

  if [ -z "$TRAVIS" ]; then
    echo "*** Remove $TMP_DIR directory manually after testing"
  fi
}
