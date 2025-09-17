# frozen_string_literal: true

module ActionPushWeb
  class Notification
    def initialize(endpoint:, p256dh_key:, auth_key:, title:, **options)
      @endpoint = endpoint
      @p256dh_key = p256dh_key
      @auth_key = auth_key
      @payload = build_payload(title, options)
    end

    def deliver(connection: nil)
      Request.new(
        message: JSON.generate(@payload),
        endpoint: @endpoint,
        p256dh: @p256dh_key,
        auth: @auth_key,
        vapid: ActionPushWeb.vapid_identification,
        connection: connection,
      ).perform
    end

    private

      # https://developer.mozilla.org/en-US/docs/Web/API/Notification/Notification#parameters
      def build_payload(title, options)
        # Merge badge and path into data
        badge = options.delete(:badge)
        path = options.delete(:path)
        data = (options.delete(:data) || {}).merge(badge: badge, path: path).compact

        { title: title, options: options.merge(data: data).compact }
      end
  end
end
