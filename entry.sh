#!/bin/sh
echo "正在构建并部署页面："
mkdocs build -c
# git config --global user.name "$GIT_USER"
# git config --global user.email "$GIT_EMAIL"
# ssh -o "StrictHostKeyChecking no" -T git@github.com
echo "页面已经发布，容器进入监视状态。"
while true; do
  find mkdocs.yml docs | entr sh -c 'mkdocs build -c'
done
