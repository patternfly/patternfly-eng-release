#!/bin/sh

# Setup env for use with GitHub
#
git_setup()
{
  echo "*** Setting up Git env"
  cd $BUILD_DIR

  # Add Angular Patternfly as a remote
  git remote rm $REPO_NAME_PTNFLY_ANGULAR
  git remote add $REPO_NAME_PTNFLY_ANGULAR https://$AUTH_TOKEN@github.com/$REPO_SLUG_PTNFLY_ANGULAR.git
  check $? "git add remote failure"

  # Add Patternfly as a remote
  git remote rm $REPO_NAME_PTNFLY
  git remote add $REPO_NAME_PTNFLY https://$AUTH_TOKEN@github.com/$REPO_SLUG_PTNFLY.git
  check $? "git add remote failure"

  # Add Patternfly Org as a remote
  git remote rm $REPO_NAME_PTNFLY_ORG
  git remote add $REPO_NAME_PTNFLY_ORG https://$AUTH_TOKEN@github.com/$REPO_SLUG_PTNFLY_ORG.git
  check $? "git add remote failure"

  # Add RCUE as the next remote
  git remote rm $REPO_NAME_RCUE
  git remote add $REPO_NAME_RCUE https://$AUTH_TOKEN@github.com/$REPO_SLUG_RCUE.git
  check $? "git add remote failure"
}

# Clone local repo and checkout branch
#
# $1: Repo slug
# $2: Branch name
setup_repo() {
  DIR=$TMP_DIR/`basename $1`
  echo "*** Setting up local repo $DIR"

  rm -rf $DIR
  mkdir -p $TMP_DIR
  cd $TMP_DIR

  git clone https://github.com/$1.git
  check $? "git clone failure"

  cd $DIR
  git checkout $2
  if [ "$?" -ne 0 ]; then
    git checkout -B $2
  fi
  check $? "git checkout failure"
}
