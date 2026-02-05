class WebhookConfig < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :project_id, :webhook_url
  validates :webhook_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }

  # 使用 YAML 序列化，兼容 Rails 7.2
  serialize :status_templates, coder: YAML, type: Hash
  serialize :enabled_statuses, coder: YAML, type: Array

  # 初始化时确保不为 nil
  after_initialize do
    self.status_templates ||= {}
    self.enabled_statuses ||= []
  end

  def self.for_project(project)
    config = where(project_id: project.id).first_or_initialize
    # 确保 enabled_statuses 是数组
    if config.enabled_statuses.is_a?(String)
      # 如果是字符串，尝试解析（可能序列化有问题）
      begin
        parsed = YAML.load(config.enabled_statuses)
        config.enabled_statuses = parsed.is_a?(Array) ? parsed : []
      rescue
        config.enabled_statuses = []
      end
    elsif !config.enabled_statuses.is_a?(Array)
      config.enabled_statuses = []
    end
    config
  end

  def status_template(status_name)
    return nil unless status_templates.is_a?(Hash)
    status_templates[status_name.to_s]
  end

  # 检查某个状态是否启用通知
  def status_enabled?(status_name)
    # 确保 enabled_statuses 是数组
    return false unless enabled_statuses.is_a?(Array)
    return false if enabled_statuses.empty?
    enabled_statuses.include?(status_name.to_s)
  end

  def enabled?
    enabled && webhook_url.present?
  end
end