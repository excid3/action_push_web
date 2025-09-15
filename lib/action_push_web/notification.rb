class ActionPushWeb::Notification
  def initialize(title:, body:, path:, endpoint:, p256dh_key:, auth_key:, badge: nil, icon: nil, urgency: :normal)
    @title, @body, @icon, @path, @badge = title, body, icon, path, badge
    @endpoint, @p256dh_key, @auth_key = endpoint, p256dh_key, auth_key
    @icon, @urgency = icon, urgency
  end

  def deliver(connection: nil)
    WebPush.payload_send \
      message: encoded_message,
      endpoint: @endpoint, p256dh: @p256dh_key, auth: @auth_key,
      vapid: ActionPushWeb.vapid_identification,
      connection: connection,
      urgency: @urgency
  end

  private
    def encoded_message
      JSON.generate title: @title, options: { body: @body, icon: @icon, data: { path: @path, badge: @badge } }.compact
    end
end
