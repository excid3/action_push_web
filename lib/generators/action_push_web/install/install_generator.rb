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

  def add_route
    route "resources :push_subscriptions"
  end

  def add_association
    association = "  has_many :push_subscriptions, class_name: \"ActionPushWeb::Subscription\", dependent: :delete_all\n"

    if ::File.exist?("app/models/#{options[:user_model].underscore}.rb")
      inject_into_class "app/models/#{options[:user_model].underscore}.rb", association, options[:user_model]
    else
      say <<~MESSAGE
        Add the following association to your User model.

          #{association}
      MESSAGE
    end
  end

  def vapid_key_config
    if ::File.exist?("config/push.yml")
      generate "action_push_web:vapid_key"
    else
      template "config/push.yml"
      say "Edit config/push.yml to set the contact URI subject for VAPID"
    end
  end

  private

  def vapid_key
    @vapid_key ||= ActionPushWeb.generate_vapid_key
  end
end
