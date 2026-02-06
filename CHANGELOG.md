# 更新日志 (Changelog)

## [1.0.2] - 2026-02-06

### 修复改进
- 修复Redmine 6.1+菜单高亮问题（使用setTimeout延时确保菜单初始化）
- 优化子项目同步逻辑，自动检测webhook模块启用状态
- 改进JavaScript代码质量（IIFE避免全局污染、严格模式）
- 完善错误处理和日志记录

### 新增功能
- **智能@提醒功能增强**: 基于用户手机号实现真正的钉钉@提醒
  - 从users表的phone字段获取指派人手机号
  - 有手机号时通过`atMobiles`参数实现真正的@提醒
  - 无手机号时仅显示`@昵称`，不触发真正@提醒

### UI/UX优化
- 优化子项目选择界面和模板输入体验
- 在模板配置页面添加@功能使用提示
- 响应式设计改进

### 文档更新
- 更新README.md中@功能说明（基于phone字段而非redmine_users插件）
- 补充手机号配置要求和效果说明

### 升级说明
```bash
cd /path/to/redmine
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
bundle exec rake tmp:cache:clear RAILS_ENV=production
```

**注意**: 如需使用完整的@提醒功能，请在users表中添加phone字段并填写用户手机号。

---

## [1.0.1] - 2026-02-05

### 新增功能
- **子项目同步**: 支持多级子项目递归同步，批量同步配置
- **智能@提醒**: 自动@任务指派人（需配合redmine_users插件）
- **富文本模板**: 支持Markdown/HTML格式，文本域输入
- **状态配置持久化**: 使用状态名称作为配置键，解决ID变化问题

### 修复改进
- 修复状态配置无法保存问题
- 修复菜单高亮问题
- 修复子项目同步重复问题
- 完善表单提交处理

### 技术优化
- 使用Rails serialize YAML序列化数组和Hash
- 数据库事务管理确保数据一致性
- 递归CTE查询优化子项目获取

### 升级说明
```bash
cd /path/to/redmine
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

---

## [1.0.0] - 2026-02-03

### 初始版本
- 基础Webhook功能
- 钉钉机器人集成
- 任务状态变更通知
- 签名验证支持
- 基础模板变量替换

---

**版本号规则**: 遵循[语义化版本控制](https://semver.org/lang/zh-CN/)

**发布历史**:
- 2026-02-06: v1.0.2 - 菜单高亮修复、子项目同步优化
- 2026-02-05: v1.0.1 - 子项目同步、@提醒、富文本模板
- 2026-02-03: v1.0.0 - 初始版本
