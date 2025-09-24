require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "application is configured" do
    assert Rails.application.present?
  end
end

