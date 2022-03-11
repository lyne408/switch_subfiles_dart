# switch subfiles

Last edited: 22.03.07

## Features

快速切换子文件.

## Use case: 不重启 cmd.exe, 使用多个 Python 版本

系统会在程序启动期间向其注入环境变量, 若程序运行中改变环境变量, 必须重启程序才有效.

设两个 Python 的目录如下:

- `D:\Program_Files\Python\__Python_binaries\python-3.8.10-amd64` (设为 py3_8_dir)
- `D:\Program_Files\Python\__Python_binaries\python-3.10.1-amd64` (设为 py3_8_dir)

将 `D:\Program_Files\Python`(设为 pyDir) 添加到 PATH 环境变量.

### 从无切换文件

1. Users 在 Windows Explorer 中拖动 `py3_8_dir` 到 `switch_subfiles.exe` 作为第一个参数传入.
2. This program 将 `py3_8_dir` 的 subfiles 全部移动至 `pyDir`.
3. This program 将在 `D:\Program_Files\Python\__Python_binaries` 中生成一个 JSON 配置文件 `switch_subfiles_config.json`.
4. This program 将在 pyDir 生成一个空的 mark 文件夹 `__current = py3_8_dir 对应的 folder name`

### 从有切换文件

1. Users 再拖动 `py3_10_dir` 到 `switch_subfiles.exe` 作为第一个参数传入.
2. This program 先将 `pyDir` 中原本属于属于 `py3_8_dir` 的 subfiles 全部移回 `py3_8_dir`,
3. This program 再将 `py3_10_dir` 的 subfiles 全部移动至 `pyDir`
4. This program 修改 `switch_subfiles_config.json` 为相应的.
5. This program 将在 pyDir 生成一个空的 mark 文件夹 `__current = py3_10_dir 对应的 folder name`

### 还原被切换的文件

1. 若 working directory 为 `D:\Program_Files\Python\__Python_binaries`(如 打开 `cmd.exe` 进入该目录),
   运行 `switch_subfiles.exe`, 不传入任何参数.
2. This program 将 `pyDir` 中原本属于 `py3_10_dir` 的 subfiles 全部移回 `py3_10_dir`.
3. This program 删除配置文件.
4. This program 删除 pyDir 那个一个空的 mark 文件夹.

## Disadvantages

- 目前配置文件存储的是绝对路径

  以后会支持相对路径, 相对于配置文件的路径

### Future Plans

目前, 本软件像极了一个没有冲突管理, 只支持单个 mod 且没有 GUI 的 mod manager.

在 Windows 上实现 mod manager, 为了便捷, 不可避免地要使用 Win32. 目前暂时没有时间.

看 Flutter for Windows 的发展吧. Dart 基础都还不牢固呢.
