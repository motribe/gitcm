#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# 初始化配置
function init() {
  # 检查参数个数
  if [ $# -ne 3 ]; then
    echo "Usage: $0 <config_name> <user_name> <user_email>"
    exit 1
  fi

  section_name=$1
  username=$2
  email=$3

  if grep -q "^\[$section_name\]" "$conf_file"; then
    echo "$section_name exists"
  else
    echo "[$section_name]" >>"$conf_file"
    echo "user.name=$username" >>"$conf_file"
    echo "user.email=$email" >>"$conf_file"
    echo "" >>"$conf_file"

    get "$section_name"
  fi
}

# 删除配置
function delete() {
  section=$1
  $ini_utils delete "$conf_file" "$section"
}

# 获取配置列表
function list() {
  sections=($($ini_utils list $conf_file))
  current_username=$(git config user.name)
  current_email=$(git config user.email)

  for section in "${sections[@]}"; do
    section_username=$($ini_utils get $conf_file $section user.name)
    section_email=$($ini_utils get $conf_file $section user.email)
    if [[ $current_username == $section_username && $current_email == $section_email ]]; then
      echo "*" "$section"
    else
      echo " " "$section"
    fi
  done
}

# 获取指定配置
function get() {
  section=$1

  $ini_utils get "$conf_file" "$section"
}

# 更新配置
function edit() {
  section=$1
  key=$2
  value=$3
  $ini_utils set "$conf_file" "$section" "$key" "$value"
}

# 获取当前配置
function current() {
  git config --list | grep user
}

# 切换配置
function use() {
  section=$1
  git config --global user.name "$($ini_utils get $conf_file $section user.name)"
  git config --global user.email "$($ini_utils get $conf_file $section user.email)"
}

main() {
  script_dir=$(cd "$(dirname "$0")" && pwd)
  ini_utils=$script_dir/util/ini-utils.sh
  conf_file=$script_dir/conf/conf.ini

  while getopts "cd:e:g:hi:lu:v" arg; do
    case $arg in
    c)
      current
      exit
      ;;
    d)
      delete $OPTARG
      exit
      ;;
    e)
      edit_args=($OPTARG)
      section=${edit_args[0]}
      key=${edit_args[1]}
      value=${edit_args[2]}
      edit $section $key $value
      exit
      ;;
    g)
      get $OPTARG
      exit
      ;;
    h)
      cat "$script_dir"/HELP.md
      exit
      ;;
    l)
      list
      exit
      ;;
    i)
      init_args=($OPTARG)
      section=${init_args[0]}
      user_name=${init_args[1]}
      user_email=${init_args[2]}
      init $section $user_name $user_email
      exit
      ;;
    u)
      use $OPTARG
      exit
      ;;
    v)
      set -o xtrace
      ;;
    ?)
      cat "$script_dir"/HELP.md
      exit 1
      ;;
    esac
  done

  # 如果没有提供任何选项，输出帮助信息
  if [ $OPTIND -eq 1 ]; then
    cat "$script_dir"/HELP.md
    exit 0
  fi
}

main "$@"
