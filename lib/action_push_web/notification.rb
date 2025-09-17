# frozen_string_literal: true

module ActionPushWeb
  class Notification
    def initialize(title:, endpoint:, p256dh_key:, auth_key:, body: nil, path: nil, badge: nil, icon: nil, urgency: :normal)
      @title, @body, @icon, @path, @badge = title, body, icon, path, badge
      @endpoint, @p256dh_key, @auth_key = endpoint, p256dh_key, auth_key
      @icon, @urgency = icon, urgency
    end

    def deliver(connection: nil)
      Request.new(
        message: encoded_message,
        endpoint: @endpoint,
        p256dh: @p256dh_key,
        auth: @auth_key,
        vapid: ActionPushWeb.vapid_identification,
        connection: connection,
        urgency: @urgency
      ).perform
    end

    private
      def encoded_message
        JSON.generate title: @title, options: { body: @body, icon: @icon, data: { path: @path, badge: @badge } }.compact
      end
  end
end
