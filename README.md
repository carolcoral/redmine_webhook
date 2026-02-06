# Redmine Webhook Plugin

Redmine webhook通知插件，支持钉钉自定义机器人消息通知，实现项目任务状态变更的实时通知。

[![Redmine](https://img.shields.io/badge/Redmine-6.1%2B-blue)](https://www.redmine.org/)
[![Ruby](https://img.shields.io/badge/Ruby-2.7%2B-red)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.2-orange)](CHANGELOG.md)

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

## ⚙️ 配置指南

### 1. 钉钉机器人设置

1. 在钉钉群中添加自定义机器人
2. 获取Webhook URL：`https://oapi.dingtalk.com/robot/send?access_token=xxx`
3. （可选）配置签名验证并获取密钥

### 2. 插件配置

进入项目 → Webhook菜单 → 配置参数：

- **启用Webhook**: 勾选激活通知
- **Webhook地址**: 填写钉钉机器人完整URL
- **密钥令牌**: 填写签名密钥（如启用签名验证）
- **通知模板**: 为每个状态自定义消息内容

### 3. 选择通知状态

在"启用通知的任务状态"区域：
- 勾选需要触发通知的任务状态
- 使用"全选"/"全不选"快速操作
- 必须至少勾选一个状态

### 4. 子项目同步（可选）

在"同步配置到子项目"区域：
- 选择需要同步配置的子项目
- 自动检测子项目是否启用了webhook模块
- 未启用webhook模块的子项目将自动禁用webhook
- 支持多级子项目（递归同步）

## 📝 通知模板

### 占位符变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `${user}` | 操作用户 | 张三 |
| `${task}` | 任务标题 | 修复登录bug |
| `${status}` | 当前状态 | 进行中 |
| `${project}` | 项目名称 | 网站开发 |
| `${url}` | 任务链接 | http://redmine.example.com/issues/123 |
| `${notes}` | 备注信息 | 已修复验证问题 |
| `${priority}` | 优先级 | 紧急 |
| `${tracker}` | 跟踪类型 | Bug |
| `${assigned_to}` | 指派人 | 李四 |

### 智能@提醒 ⚠️

当通知内容包含`${assigned_to}`变量或任务有指派人时，可在消息中显示指派人信息。

**重要说明：**
- **当前版本不支持真正的@功能**，仅在消息内容中显示指派人名称
- 如需实现真正的钉钉@功能，需要：
  1. 安装[redmine_users](https://github.com/carolcoral/redmine_users)插件获取用户手机号
  2. 在钉钉机器人中配置用户手机号映射
  3. 在消息结构中传入`atMobiles`参数

**示例：**
```markdown
${user} 更新了任务 "${task}"
状态：${status}
指派人：${assigned_to}

查看详情：${url}
```

> **注意**: 当前版本仅在消息文本中显示指派人名称，不会真正触发钉钉的@提醒功能。

### 模板示例

**Markdown格式（支持HTML）:**
```markdown
## ${project} - 任务更新

**任务:** ${task}  
**状态:** ${status}  
**操作人:** ${user}  
**指派人:** ${assigned_to}

> ${notes}

[查看详情](${url})
```

**纯文本格式:**
```
${user} 更新了 ${task} 状态为 ${status}
项目: ${project}
详情: ${url}
```

## 🎯 使用场景

- **任务创建**: 新任务提交时通知团队
- **状态流转**: 任务状态变更时自动提醒
- **关键状态**: 仅"已完成"等关键状态通知负责人
- **全流程跟踪**: 所有状态变化实时同步
- **项目层级同步**: 父项目配置一键同步到所有子项目
- **团队协作**: 自动@相关成员，提升响应效率

## 🔧 技术栈

- **Redmine**: 6.1+
- **Ruby**: 2.7+
- **Rails**: 6.1+ (兼容 Rails 7.2)
- **数据库**: SQLite/PostgreSQL/MySQL
- **消息格式**: Markdown/纯文本（自动检测）

## 📄 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件

## 📋 更新日志

详细的版本更新记录请查看 [CHANGELOG.md](CHANGELOG.md) 文件。

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 👤 作者

**carolcoral**

- GitHub: [@carolcoral](https://github.com/carolcoral)
- 项目地址: [https://github.com/carolcoral/redmine_webhook](https://github.com/carolcoral/redmine_webhook)
