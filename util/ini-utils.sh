#!/usr/bin/env bash

# 定制化shell输出
function custom_print() {
  echo -e "\033[5;34m ***** \033[0m"
  echo -e "\033[32m $@ ! \033[0m"
  echo -e "\033[5;34m ***** \033[0m"
}

function list_section() {
  local file=$1
  awk '/^\[.*\]$/ { sub(/\[/, ""); sub(/\]/, ""); print $0 }' "$file"
}

# 检查 INI 文件中指定的 section 是否存在
function check_section() {
  local file="$1"
  local section_name="$2"

  if grep -q "^\[$section_name\]" "$file"; then
    echo "Section $section_name exists in $file"
  else
    echo "Section $section_name does not exist in $file"
  fi
}

# 定义函数来打印指定 section 的内容
function print_section() {
  local file="$1"
  local section_name="$2"

  awk -v section="$section_name" '/^\[/ {flag=($0 ~ "[[" section "]]"); next} flag' "$file"
}

# 获取配置文件指定section指定key的value
function get_opt() {
  local file=$1
  local section=$2
  local key=$3
  local val=$(awk -F "$delimiter" '/\['$section'\]/{a=1}a==1&&$1~/'$key'/{print $2;exit}' "$file")
  echo "$val"
}

# 更新配置文件指定section指定key的value
function set_opt() {
  local ini_file=$1
  local section_name=$2
  local key=$3
  local new_value=$4

  # 临时文件用于保存修改后的内容
  local temp_file=$(mktemp)

  # 标志变量，用于判断是否在指定的 section 中
  local in_section=false

  # 读取 INI 文件，并进行修改
  while IFS='' read -r line; do

    # 如果是 section 开始行
    if [[ $line == "[$section_name]" ]]; then
      in_section=true
    # 如果是新的 section 开始行，结束当前 section 的处理
    elif [[ $line =~ ^\[.*\]$ && $in_section == true ]]; then
      in_section=false
    # 如果在指定 section 中，且找到了指定的 key，进行修改
    elif [ $in_section == true ] && [[ $line =~ ^$key\ *=.* ]]; then
      line="$key=$new_value"
    fi

    # 将处理后的行写入临时文件
    echo "$line" >>"$temp_file"
  done <"$ini_file"

  # 将临时文件替换原文件
  mv "$temp_file" "$ini_file"
}

function delete_opt() {
  local file="$1"
  local section="$2"

  # 临时文件用于存储修改后的内容
  local temp_file="temp.ini"

  # 使用 awk 命令删除指定的 section 及其内容
  awk 'BEGIN {section="'$section'"}
        /^\[/ {
            if ($0 ~ "\\[" section "\\]") {
                in_section = 1
            } else {
                in_section = 0
            }
        }
        {
            if (!in_section) {
                print
            }
        }' "$file" >"$temp_file"

  # 将临时文件的内容覆盖回原文件
  mv "$temp_file" "$file"
}

#【脚本说明】
#1、此脚本适用操作.ini配置文件内容；
#2、可以读取或更新指定section指定key的value；
main() {
  # key和value的分隔符，即等号两边有没有空格
  delimiter='='

  # 操作参数
  operate=$1
  # 操作文件
  file=$2
  # 指定section
  section=$3
  # 指定key
  key=$4
  # value
  value=$5

  # 提示信息
  msg="Please input the param 【<get|set> <file> <section> <key> [value]】"

  # 判断输入参数
  if [[ -z $operate || $operate == "help" || $operate == "-h" ]]; then
    custom_print "$msg"
  elif [[ $operate == "list" ]]; then
    list_section "$file"
  elif [[ -z $section ]]; then
    custom_print "$msg"
  elif [[ $operate == "check" ]]; then
    check_section "$file" "$section"
  elif [[ $operate == "delete" ]]; then
    delete_opt "$file" "$section"
  elif [[ $operate == "get" ]]; then
    if [[ -z $key ]]; then
      print_section "$file" "$section"
    else
      val=$(get_opt "$file" "$section" "$key")
      echo "$val"
    fi
  elif [[ -z $key ]]; then
    custom_print "$msg"
  elif [[ $operate == "set" && $value ]]; then
    set_opt "$file" "$section" "$key" "$value"
  else
    custom_print "$msg"
  fi
}

main "$@"
