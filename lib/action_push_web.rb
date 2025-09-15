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
  def self.vapid_identification
    {
      subject: Rails.application.config.action_push_web.subject,
      public_key: vapid_public_key,
      private_key: vapid_private_key
    }
  end

  def self.vapid_private_key
    ENV.fetch("VAPID_PRIVATE_KEY", Rails.application.credentials.dig(:vapid, :private_key))
  end

  def self.vapid_public_key
    ENV.fetch("VAPID_PUBLIC_KEY", Rails.application.credentials.dig(:vapid, :public_key))
  end
end
