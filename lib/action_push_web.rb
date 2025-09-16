require "action_push_web/version"
require "action_push_web/engine"

require "concurrent"
require "net/http/persistent"
require "web-push"

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.ignore("#{__dir__}/generators")
loader.ignore("#{__dir__}/tasks")
loader.setup

module ActionPushWeb
  mattr_accessor :pool

  class << self
    def vapid_identification
      {
        subject: Rails.application.config.action_push_web.subject,
        public_key: vapid_public_key,
        private_key: vapid_private_key
      }
    end

    def vapid_private_key
      ENV.fetch("VAPID_PRIVATE_KEY", Rails.application.credentials.dig(:action_web_push, :vapid_private_key))
    end

    def vapid_public_key
      ENV.fetch("VAPID_PUBLIC_KEY", Rails.application.credentials.dig(:action_web_push, :vapid_public_key))
    end

    def queue(payload, subscriptions)
      pool.queue(payload, subscriptions)
    end
  end
end
