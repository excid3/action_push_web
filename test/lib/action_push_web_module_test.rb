require "test_helper"

class ActionPushWebModuleTest < ActiveSupport::TestCase
  test "generates VAPID key" do
    vapid_key = ActionPushWeb.generate_vapid_key

    assert_instance_of ActionPushWeb::VapidKey, vapid_key
  end

  test "has version" do
    assert ActionPushWeb::VERSION.present?
  end
end
