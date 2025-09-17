# Action Push Web

Action Push Web is a Rails web push notification gem for PWAs.

## Installation

```bash
bundle add action_push_web
bin/rails action_push_web:install:migrations
bin/rails db:migrate
bin/rails g action_push_web:install
```

## Configuration

To load VAPID details from ENV or Rails credentials, use ERB in `config/push.yml`.

```yaml
# config/push.yml
shared:
  web:
    vapid:
      subject: <%= ENV["VAPID_SUBJECT"] || Rails.application.credentials.dig(:vapid, :subject) %>
      public_key: <%= ENV["VAPID_PUBLIC_KEY"] || Rails.application.credentials.dig(:vapid, :public_key) %>
      private_key: <%= ENV["VAPID_PRIVATE_KEY"] || Rails.application.credentials.dig(:vapid, :private_key) %>
```

## Sending Notifications

You can send notifications to one subscription or many using the pool.

### Sending to a single subscription

```ruby
Current.user.push_subscriptions.notification(title: "Hello world")
```

### Sending to many subscriptions

```ruby
subscriptions = ActionPushWeb::Subscription.all
ActionPushWeb.queue({title: "Hello world"}, subscriptions)
```

## Debugging

Ensure that your operating system settings allow notifications for your browser.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
