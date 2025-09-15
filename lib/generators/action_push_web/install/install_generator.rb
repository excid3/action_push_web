# frozen_string_literal: true

class ActionPushWeb::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  class_option :user_model, type: :string, default: "User"
  class_option :current_user, type: :string, default: "Current.user"

  def copy_files
    template "app/javascript/controllers/notifications_controller.js"
    template "app/controllers/push_subscriptions_controller.rb"
    template "app/views/pwa/service-worker.js"
    template "app/views/push_subscriptions/index.html.erb"
    template "app/views/push_subscriptions/_push_subscription.html.erb"
  end

  def add_association
    inject_into_class "app/models/#{options[:user_model].underscore}.rb", options[:user_model] do
      "  has_many :push_subscriptions, class_name: \"ActionPushWeb::Subscription\", dependent: :delete_all\n"
    end
  end

  def add_route
    route "resources :push_subscriptions"
  end
end
