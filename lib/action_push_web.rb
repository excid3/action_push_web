# frozen_string_literal: true

require "action_push_web/version"
require "action_push_web/engine"

require "base64"
require "jwt"
require "openssl"
require "concurrent"
require "net/http/persistent"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.ignore("#{__dir__}/generators")
loader.ignore("#{__dir__}/tasks")
loader.setup

module ActionPushWeb
  mattr_accessor :pool

  class << self
    def generate_vapid_key
      VapidKey.new
    end

    def vapid_identification
      config = Rails.application.config_for(:push).dig(:web, :vapid)
      raise "ActionPushWeb: 'web' platform is not configured with VAPID. Run `bin/rails generate action_push_web:vapid_key` to configure it." unless config.present?
      config
    end

    def queue(payload, subscriptions)
      pool.queue(payload, subscriptions)
    end
  end
end
