#!/bin/bash

# 加载 cargo 环境
source $HOME/.bashrc

# 总是彩色打印 cargo 信息
export CARGO_TERM_COLOR=always

# Current dir: /ci
echo PWD=$PWD && ls -alh

# install latest os-checker
echo "DEBUG=$DEBUG"
if [[ "$DEBUG" == 1 ]]; then
  echo 'compile os-checker from github source'
  git clone https://github.com/os-checker/os-checker.git
  cargo install --path os-checker
  export RUST_LOG=trace
else
  echo 'download os-checker from github release'
  curl -s https://api.github.com/repos/os-checker/os-checker/releases/latest |
    grep browser_download_url |
    grep os-checker-installer.sh |
    cut -d '"' -f 4 |
    wget -qi -
  echo 'os-checker-installer.sh is downloaded'
  sh os-checker-installer.sh
fi
os-checker --help

# handle ansi via ansi2html or ansi2txt
# apt install --silent -y colorized-logs

# prepare os-checker configuration file
# cp repos.yaml /check/
# cd /check
# Current dir: /check

# os-checker 2>&1 >summary.out
# echo '```text' >>summary.txt
# ansi2txt <summary.out >>summary.txt
# echo '```' >>summary.txt

# ls -alh && echo PWD = $PWD
os-checker --emit json --norun --setup # set up toolchains for all repos and checkers
os-checker --emit /check/ui.json       # to be moved into ci/os-checks/content

# /check 目录在 github action 和 Docker 容器之间共享

# github pages dir
# mkdir /check/.gh-pages
# ansi2html <summary.out >/check/.gh-pages/index.html

# 构建网页应用，并从容器移至 Github Action 目录，待部署到 Github Pages
cd os-checks && npm install && npm run generate && cp -LR dist /check/
