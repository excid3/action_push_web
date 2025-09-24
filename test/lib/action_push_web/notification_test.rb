require "test_helper"

class ActionPushWeb::NotificationTest < ActiveSupport::TestCase
  setup do
    @notification = ActionPushWeb::Notification.new(
      endpoint: "https://test-push-service.example.com/endpoint/test-456",
      p256dh_key: "BTestNotificationKeyTestNotificationKeyTestNotificationKeyTestNotificationKey",
      auth_key: "testNotificationAuth789",
      title: "Test Notification"
    )
  end

  test "builds payload with title" do
    payload = @notification.instance_variable_get(:@payload)

    assert_equal "Test Notification", payload[:title]
    assert payload[:options].present?
  end

  test "merges badge and path into data" do
    notification = ActionPushWeb::Notification.new(
      endpoint: "https://test-push-service.example.com/endpoint/badge-test",
      p256dh_key: "BTestBadgeKeyTestBadgeKeyTestBadgeKeyTestBadgeKeyTestBadgeKey",
      auth_key: "testBadgeAuth999",
      title: "Test",
      badge: 5,
      path: "/notifications"
    )

    payload = notification.instance_variable_get(:@payload)
    data = payload[:options][:data]

    assert_equal 5, data[:badge]
    assert_equal "/notifications", data[:path]
  end

  test "compacts nil values" do
    notification = ActionPushWeb::Notification.new(
      endpoint: "https://test-push-service.example.com/endpoint/compact-test",
      p256dh_key: "BTestCompactKeyTestCompactKeyTestCompactKeyTestCompactKey",
      auth_key: "testCompactAuth888",
      title: "Test",
      icon: nil,
      badge: 1
    )

    payload = notification.instance_variable_get(:@payload)
    options = payload[:options]

    assert_not options.key?(:icon)
    assert_equal 1, options[:data][:badge]
  end
end
