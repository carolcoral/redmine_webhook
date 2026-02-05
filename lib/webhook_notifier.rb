require 'uri'
require 'net/http'
require 'json'
require 'openssl'
require 'base64'

class WebhookNotifier
  def self.notify(issue, webhook_config)
    new(webhook_config).send_notification(issue)
  end

  def initialize(webhook_config)
    @webhook_config = webhook_config
    @project = webhook_config.project
  end

  def send_notification(issue)
    unless @webhook_config.enabled?
      return false
    end
    
    status_name = issue.status.name
    template = @webhook_config.status_template(status_name)
    unless template.present?
      Rails.logger.warn "[Webhook] No template found for status '#{status_name}'"
      return false
    end

    message = build_message(issue, template)
    send_to_dingtalk(message)
  rescue StandardError => e
    Rails.logger.error "[Webhook] Failed to send notification: #{e.message}"
    false
  end

  private

  def build_message(issue, template)
    # Get current user from journal if available
    current_user = if issue.current_journal && issue.current_journal.user
                     issue.current_journal.user.name
                   else
                     issue.author.name
                   end

    # Get assignee (指派人)
    assigned_to = if issue.assigned_to
                    issue.assigned_to.name
                  else
                    '未指派'
                  end

    placeholders = {
      '${user}' => current_user,
      '${task}' => issue.subject,
      '${status}' => issue.status.name,
      '${project}' => issue.project.name,
      '${url}' => issue_url(issue),
      '${notes}' => issue.current_journal.try(:notes) || '',
      '${priority}' => issue.priority.try(:name) || '',
      '${tracker}' => issue.tracker.try(:name) || '',
      '${assigned_to}' => assigned_to
    }

    message_text = template.dup
    placeholders.each do |placeholder, value|
      message_text.gsub!(placeholder, value.to_s)
    end

    # Check if template contains Markdown or HTML syntax
    # 检测Markdown语法: #标题, *斜体*, `代码`, _下划线_, [链接](url)
    # 检测HTML标签: <div>, <p>, <strong>, <b>, <i>, <u>, <a>, <img>, <table>, <ul>, <ol>, <li>
    if template.match?(/[#*`_\[\]]/) || template.match?(/<\/?(div|p|strong|b|i|u|a|img|table|ul|ol|li|h\d|br|hr|pre|code|span)[^>]*>/i)
      # Use Markdown format (DingTalk Markdown also supports basic HTML)
      {
        msgtype: 'markdown',
        markdown: {
          title: "#{issue.project.name} - #{issue.subject}",
          text: message_text
        }
      }
    else
      # Use plain text format
      {
        msgtype: 'text',
        text: {
          content: message_text
        }
      }
    end
  end

  def send_to_dingtalk(message)
    Rails.logger.info "[WebhookNotifier] Original webhook URL: #{@webhook_config.webhook_url}"
    Rails.logger.info "[WebhookNotifier] Secret token present: #{@webhook_config.secret_token.present?}"
    
    uri = URI.parse(@webhook_config.webhook_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'

    payload = message.to_json
    
    # 保存原始URL用于日志
    final_uri = uri.dup
    
    # Add signature if secret token is configured
    if @webhook_config.secret_token.present?
      timestamp = (Time.now.to_f * 1000).to_i
      sign = generate_sign(timestamp, @webhook_config.secret_token)
      
      # 保留原有的 query 参数并添加签名参数
      params = URI.decode_www_form(uri.query || '').to_h
      params['timestamp'] = timestamp
      params['sign'] = sign
      final_uri.query = URI.encode_www_form(params)
      
      Rails.logger.info "[WebhookNotifier] Added signature to URL"
    end

    Rails.logger.info "[WebhookNotifier] Final webhook URL: #{final_uri}"
    Rails.logger.info "[WebhookNotifier] Has access_token: #{final_uri.query&.include?('access_token') ? 'yes' : 'no'}"
    Rails.logger.info "[WebhookNotifier] Request payload: #{payload}"

    request = Net::HTTP::Post.new(final_uri.request_uri)
    request.content_type = 'application/json'
    request.body = payload
    
    response = http.request(request)
    
    if response.code == '200'
      result = JSON.parse(response.body)
      if result['errcode'] == 0
        Rails.logger.info "[Webhook] Notification sent successfully to #{@project.name}"
        true
      else
        Rails.logger.error "[Webhook] DingTalk API error: #{result['errmsg']}"
        false
      end
    else
      Rails.logger.error "[Webhook] HTTP error: #{response.code}"
      false
    end
  end

  def generate_sign(timestamp, secret)
    string_to_sign = "#{timestamp}\n#{secret}"
    hash = OpenSSL::HMAC.digest('SHA256', secret, string_to_sign)
    Base64.encode64(hash).strip
  end

  def issue_url(issue)
    Setting.protocol + '://' + Setting.host_name + '/issues/' + issue.id.to_s
  end
end