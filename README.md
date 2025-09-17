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
push_subscription = Current.user.push_subscriptions.last
push_subscription.notification(title: "Hello world", body: Random.uuid, path: notifications_path)
```

### Sending to many subscriptions

```ruby
push_subscriptions = ActionPushWeb::Subscription.all
ActionPushWeb.queue({ title: "Hello world", body: Random.uuid, path: notifications}, push_subscriptions)
```

## Debugging
Ensure that your operating system settings allow notifications for your browser.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits
This library is based on [pushpad/web-push](https://github.com/pushpad/web-push)
