require 'redmine'

# 获取插件根目录
plugin_root = File.dirname(__FILE__)

# 在插件加载时立即加载所有必要的文件
# 按正确的顺序加载以避免依赖问题
require File.join(plugin_root, 'lib', 'webhook_notifier')
require File.join(plugin_root, 'lib', 'webhook_issue_hook')

Redmine::Plugin.register :redmine_webhook do
  name 'Redmine Webhook Plugin'
  author 'carolcoral'
  description 'Webhook notification plugin for Redmine with DingTalk support'
  version '1.0.2'
  url 'https://github.com/carolcoral/redmine_webhook'
  author_url 'https://github.com/carolcoral'

  project_module :webhook do
    permission :manage_webhook, {:webhook_settings => [:index, :update]}
  end

  menu :project_menu, :webhook, { :controller => 'webhook_settings', :action => 'index' },
       :caption => :label_webhook,
       :after => :settings,
       :param => :project_id
end

# 确保钩子被 Redmine 识别
Rails.configuration.to_prepare do
  # 使用 require_dependency 确保在开发环境下重新加载
  require_dependency 'webhook_issue_hook'
  
  # 注册钩子
  Redmine::Hook.add_listener(WebhookIssueHook)
  
  Rails.logger.info "[WebhookPlugin] Webhook plugin initialized"
  Rails.logger.info "[WebhookPlugin] WebhookIssueHook registered as listener: #{Redmine::Hook.listeners.include?(WebhookIssueHook)}"
end