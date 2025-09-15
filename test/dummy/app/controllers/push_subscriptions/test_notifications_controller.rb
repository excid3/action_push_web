class Users::PushSubscriptions::TestNotificationsController < ApplicationController
  before_action :set_push_subscription

  def create
    @push_subscription.notification(title: "ActionPushWeb Test", body: Random.uuid, path: push_subscriptions_url).deliver
    redirect_to push_subscriptions_url
  end

  private
    def set_push_subscription
      @push_subscription = ActionPushWeb::Subscription.find(params[:push_subscription_id])
    end
end
