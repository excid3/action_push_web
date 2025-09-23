require "test_helper"

class ActionPushWeb::VapidKeyTest < ActiveSupport::TestCase
  test "generates VAPID key pair" do
    vapid_key = ActionPushWeb::VapidKey.new

    assert_respond_to vapid_key, :public_key
    assert_respond_to vapid_key, :private_key
    assert_respond_to vapid_key, :curve
  end

  test "creates from existing keys" do
    original = ActionPushWeb::VapidKey.new
    recreated = ActionPushWeb::VapidKey.from(
      public_key: original.public_key,
      private_key: original.private_key
    )

    assert_equal original.public_key, recreated.public_key
    assert_equal original.private_key, recreated.private_key
  end

  test "generates different keys each time" do
    key1 = ActionPushWeb::VapidKey.new
    key2 = ActionPushWeb::VapidKey.new

    assert_not_equal key1.public_key, key2.public_key
  end
end