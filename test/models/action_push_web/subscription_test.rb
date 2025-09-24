require "test_helper"

class ActionPushWeb::SubscriptionTest < ActiveSupport::TestCase
  setup do
    @subscription = ActionPushWeb::Subscription.new(
      endpoint: "https://test-push-service.example.com/endpoint/test-123",
      p256dh_key: "BTestKey123TestKey123TestKey123TestKey123TestKey123TestKey123TestKey123",
      auth_key: "testAuthKey123456"
    )
  end

  test "creates notification with subscription details" do
    notification = @subscription.notification(title: "Test", body: "Test message")

    assert_instance_of ActionPushWeb::Notification, notification
  end

  test "parses user agent" do
    @subscription.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"

    assert_respond_to @subscription, :browser
    assert_respond_to @subscription, :platform
    assert_respond_to @subscription, :version
  end

  test "belongs to polymorphic owner" do
    user = User.create!(email_address: "test@example.com", password: "password")
    @subscription.owner = user
    @subscription.save!

    assert_equal user, @subscription.owner
  end
end
