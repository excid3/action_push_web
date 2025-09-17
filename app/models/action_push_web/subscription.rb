# frozen_string_literal: true

class ActionPushWeb::Subscription < ApplicationRecord
  belongs_to :owner, polymorphic: true

  delegate :browser, :platform, :version, to: :parsed_user_agent

  def notification(**params)
    ActionPushWeb::Notification.new(**params, endpoint: endpoint, p256dh_key: p256dh_key, auth_key: auth_key)
  end

  def parsed_user_agent
    UserAgent.parse(user_agent)
  end
end

ActiveSupport.run_load_hooks :action_push_web_subscription, ActionPushWeb::Subscription
