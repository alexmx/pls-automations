#!/bin/zsh
# @pls.description: Open the current git repository's page on GitHub or GitLab in the browser
# @pls.param page: enum(home|pulls|issues|actions) = home -- Which page; pulls are pull requests, actions is CI
# @pls.example: open this repo on github
# @pls.example: show the pull requests for this repo
# @pls.example: open the CI page
# @pls.example: open the issues for this repo

remote=$(git remote get-url origin 2>/dev/null)
if [[ -z $remote ]]; then
  echo "This folder isn't a git repository with an origin remote." >&2
  exit 1
fi

# git@host:owner/repo.git, ssh://git@host/owner/repo.git or https://host/owner/repo(.git) → https://host/owner/repo
url=$(print -r -- "$remote" | sed -E 's#^(ssh://)?git@([^:/]+)[:/]#https://\2/#; s#\.git$##; s#/$##')
case $url in
  *gitlab*) suffixes=(home '' pulls /-/merge_requests issues /-/issues actions /-/pipelines) ;;
  *) suffixes=(home '' pulls /pulls issues /issues actions /actions) ;;
esac
typeset -A suffix=($suffixes)
url+=${suffix[$PLS_PAGE]}

open "$url" && echo "Opened $url"
