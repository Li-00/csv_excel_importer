# csv_excel_importer

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 项目说明
用于 csv，spreadsheet_decoder 插件导入 csv，excel 文件性能验证
数据库 sqlite


## 项目结构
date 路径是 sql 脚本及数据库，生成文件的 python 逻辑
lib 是 dart 策略

## 配置
    需要安装 python 环境，并安装 pandas 库 openpyxl 库
python 版本：3.10.0
pandas 版本：1.5.3

安装 pandas 库
```bash
    pip install pandas
    pip install openpyxl
```
如果提示异常，请使用以下命令安装：
```bash
 python -m pip install pandas
 python -m pip install openpyxl
```
