module ActionPushWeb
  class Engine < ::Rails::Engine
    isolate_namespace ActionPushWeb

    config.action_push_web = ActiveSupport::OrderedOptions.new

    initializer "action_push_web.request" do
      WebPush::Request.prepend PersistentRequest
    end
  end
end
