module ActionPushWeb
  module ApplicationHelper
    def when_web_notifications_disabled(**attrs, &block)
      content_tag("action-push-web-denied", capture(&block), **attrs)
    end

    def when_web_notifications_allowed(href: push_subscriptions_path,
      service_worker_url: pwa_service_worker_path(format: :js), **attrs, &block)
      content_tag("action-push-web-granted", capture(&block),
        href:, "service-worker-url" => service_worker_url,
        "public-key" => ActionPushWeb.vapid_identification.public_key, **attrs)
    end

    def ask_for_web_notifications(**attrs, &block)
      content_tag("action-push-web-request", capture(&block), **attrs)
    end
  end
end
