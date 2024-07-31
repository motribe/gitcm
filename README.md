# gitcm(git config manager)

## 简介
这是一个git配置管理的 shell 脚本项目，用于在多套git配置中进行切换。

## 功能特点
- 新增git配置
- 删除git配置
- 获取git配置列表
- 获取指定的git配置
- 更新git配置
- 获取当前git使用的配置
- 切换git配置

## 安装
1. 确保您的系统已安装git。
2. 克隆本项目到您的本地目录：
   `git clone [项目仓库地址]`
3. 进入项目目录并将gitcm.sh添加到系统环境变量

## 使用


```bash
gitcm.sh
Usage: ./gitcm.sh {options}

This is git config manage script.

你可以使用如下参数进行操作
-c                               查看当前配置
-d {config_name}                 删除指定配置
-e {config_name} {key} {value}   编辑指定配置
-g {config_name}                 获取指定配置
-h                               输出帮助信息
-l                               输出配置列表
-i {config_name}                 初始化新配置
-u                               切换配置
-v                               输出调试信息
-?                               输出帮助信息
```

## 示例
以下是一些使用本脚本的示例：

1. 新增git配置

   ```bash
   $ gitcm.sh -i "config1 example email@example.com"
   user.name=example
   user.email=email@example.com
   ```

2. 获取git配置列表

   ```bash
   $ gitcm.sh -l
     config1
   ```

3. 获取指定的git配置

   ```bash
   $ gitcm.sh -g config1
   user.name=example
   user.email=email@example.com
   ```

4. 更新git配置

   ```bash
   $ gitcm.sh -e "config1 user.name example2"
   ```

5. 切换git配置

   ```bash
   $ gitcm.sh -u config1
   ```

6. 获取当前git使用的配置

   ```bash
   $ gitcm.sh -c
   user.name=example2
   user.email=email@example.com
   ```

## 贡献
如果您想要为这个项目做出贡献，欢迎提交 pull request 或者提出 issue。

## 许可证
本项目使用 [许可证名称] 许可证。

## 作者
moluo

## 联系方式
如果您有任何问题或建议，请通过 [联系邮箱] 或 [其他联系方式] 与我联系。