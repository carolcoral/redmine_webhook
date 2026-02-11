# Redmine Webhook Plugin

Redmine webhook通知插件，支持钉钉自定义机器人消息通知，实现项目任务状态变更的实时通知。

[![Redmine](https://img.shields.io/badge/Redmine-6.1%2B-blue)](https://www.redmine.org/)
[![Ruby](https://img.shields.io/badge/Ruby-2.7%2B-red)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.2-orange)](CHANGELOG.md)



## 获取方式
- 通过 [**XIN·DU Product**](https://blog.xindu.site/shop/product/2) 直接在线购买
- 更多内容可联系 [**咸鱼**](https://www.goofish.com/item?spm=a21ybx.personal.feeds.1.482c6ac2BLkUG3&id=1022520404886&categoryId=50023914)

## ✨ 核心特性

- **项目级独立配置**: 每个项目可独立设置Webhook
- **状态多选控制**: 自由选择哪些状态变更时触发通知
- **富文本模板**: 支持Markdown和HTML格式
- **智能变量替换**: 9个内置占位符自动替换
- **钉钉签名验证**: 支持钉钉机器人安全设置
- **子项目同步**: 一键将配置同步到所有子项目
- **智能@提醒**: 自动@任务指派人（钉钉）
- **模块感知**: 自动检测子项目是否启用webhook模块

## 📦 快速安装

```bash
cd /path/to/redmine/plugins
git clone https://github.com/carolcoral/redmine_webhook.git
cd /path/to/redmine
bundle install
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
# 重启Redmine服务
```
