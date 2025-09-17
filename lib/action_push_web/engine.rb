# frozen_string_literal: true

module ActionPushWeb
  class Engine < ::Rails::Engine
    isolate_namespace ActionPushWeb

    config.action_push_web = ActiveSupport::OrderedOptions.new
    config.action_push_web.invalid_subscription_handler = ->(subscription_id) do
      Rails.application.executor.wrap do
        Rails.logger.info "Destroying Action Push Web subscription: #{subscription_id}"
        ActionPushWeb::Subscription.destroy_by(id: subscription_id)
      end
    end

    config.after_initialize do
      ActionPushWeb.pool ||= Pool.new(invalid_subscription_handler: config.action_push_web.invalid_subscription_handler)
      at_exit { ActionPushWeb.pool.shutdown }
    end
  end
end
