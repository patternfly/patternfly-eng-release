#!/bin/sh

default()
{
  # Add paths to env (non-Travis build)
  if [ -z "$TRAVIS" ]; then
    PATH=/usr/local/bin:/usr/bin:/bin:$PATH
    export PATH
  fi

  SCRIPT=`basename $0`
  SCRIPT_DIR=`dirname $0`
  SCRIPT_DIR=`cd $SCRIPT_DIR; pwd`

  . $SCRIPT_DIR/../_env.sh
  . $SCRIPT_DIR/../_common.sh
  . $SCRIPT_DIR/_common.sh

  BUILD_DIR=$TRAVIS_BUILD_DIR
}

# Check prerequisites before continuing
#
prereqs()
{
  merge_prereqs

  if [ ! -s "$PACKAGE_JSON" -o ! -s "$BOWER_JSON" ]; then
    echo "*** Cannot locate $PACKAGE_JSON or $BOWER_JSON. Do not bump!"
    exit 1
  fi

  # Get version generated by 'semantic-release pre'
  VERSION=`grep version $PACKAGE_JSON | \
           awk -F':' '{print $2}' | \
           sed 's|"||g' | \
           sed 's|,||g' |
           sed 's| *||g'`

  BOWER_VERSION=`grep version $BOWER_JSON | \
           awk -F':' '{print $2}' | \
           sed 's|"||g' | \
           sed 's|,||g' |
           sed 's| *||g'`

  if [ "$VERSION" != "$BOWER_VERSION" ]; then
    echo "*** The $PACKAGE_JSON and $BOWER_JSON versions differ. Do not publish!"
    exit 1
  fi
}

# Publish to npm
#
publish_npm()
{
  #npm publish
  check $? "npm publish failure"
}

usage()
{
cat <<- EEOOFF

    This script ensures both $PACKAGE_JSON and $BOWER_JSON have been updated prior to publishing to npm

    sh [-x] $SCRIPT [-h]

    Example: sh $SCRIPT

    OPTIONS:
    h       Display this message (default)

EEOOFF
}

# main()
{
  default

  while getopts hap c; do
    case $c in
      h) usage; exit 0;;
      \?) usage; exit 1;;
    esac
  done

  prereqs
  publish_npm
}
