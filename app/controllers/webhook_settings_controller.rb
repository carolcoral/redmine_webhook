class WebhookSettingsController < ApplicationController
  helper :webhook_settings
  before_action :find_project
  before_action :authorize

  def index
    @webhook_config = WebhookConfig.for_project(@project)
    @issue_statuses = IssueStatus.sorted.to_a
  end

  def update
    @webhook_config = WebhookConfig.for_project(@project)
    
    # 确保 enabled_statuses 是数组
    if params[:webhook_config] && params[:webhook_config][:enabled_statuses].present?
      params[:webhook_config][:enabled_statuses] = params[:webhook_config][:enabled_statuses].reject(&:blank?).map(&:to_s)
    end
    
    if @webhook_config.update(webhook_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_webhook_settings_path(@project)
    else
      @issue_statuses = IssueStatus.sorted.to_a
      render :index
    end
  rescue => e
    Rails.logger.error "[Webhook] Failed to save webhook config: #{e.message}"
    @issue_statuses = IssueStatus.sorted.to_a
    render :index
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def webhook_params
    # 记录原始参数用于调试
    Rails.logger.info "[WebhookParams] Raw params: #{params[:webhook_config].inspect}"
    Rails.logger.info "[WebhookParams] Raw enabled_statuses: #{params[:webhook_config][:enabled_statuses].inspect}" if params[:webhook_config]
    
    # 获取基本参数，明确声明 enabled_statuses 是数组
    permitted = params.require(:webhook_config).permit(
      :webhook_url, :enabled, :secret_token, enabled_statuses: []
    )
    
    Rails.logger.info "[WebhookParams] After permit: #{permitted.inspect}"
    
    # 单独处理 status_templates，因为它包含动态键
    if params[:webhook_config][:status_templates]
      permitted[:status_templates] = params[:webhook_config][:status_templates].to_unsafe_h
    else
      permitted[:status_templates] = {}
    end
    
    # 确保 enabled_statuses 不为 nil（Rails 5+ 中 permit 后的数组参数可能为 nil）
    permitted[:enabled_statuses] ||= []
    # 过滤空值（来自隐藏字段的 ""）
    permitted[:enabled_statuses] = permitted[:enabled_statuses].reject { |v| v.blank? }.map(&:to_s)
    
    Rails.logger.info "[WebhookParams] Final permitted: #{permitted.inspect}"
    permitted
  end
end