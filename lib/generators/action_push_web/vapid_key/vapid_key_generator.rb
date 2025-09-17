# frozen_string_literal: true

class ActionPushWeb::VapidKeyGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  class_option :subject, type: :string, default: "mailto:user@example.org"

  def generate_vapid_key
    vapid_key = WebPush.generate_key
    say <<~MESSAGE
      Add the following to config/push.yml:

      shared:
        web:
          vapid:
            # Subject is a contact URI for the application server. Either a "mailto:" or an "https:" address
            subject: #{options[:subject]}
            public_key: #{vapid_key.public_key}
            private_key: #{vapid_key.private_key}
    MESSAGE
  end
end
