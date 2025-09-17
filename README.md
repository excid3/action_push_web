# Action Push Web

Action Push Web is a Rails web push notification gem for PWAs using the [Push API](https://developer.mozilla.org/en-US/docs/Web/API/Push_API).

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

## How It Works

Web Push notifications require the following setup:

1. Register service worker triggered by user gesture (like clicking a button).
2. Request Notification permission from browser
3. Once granted, [subscribe](https://developer.mozilla.org/en-US/docs/Web/API/PushManager/subscribe) to the push service using service worker registration
4. Store [PushSubscription](https://developer.mozilla.org/en-US/docs/Web/API/PushSubscription) in backend database
5. Backend sends notification using PushSubscription endpoint
6. Service worker receives [`push`]() event and shows Notification

## JavaScript

Using the generated Stimulus controller for Notifications, we can add a button that attempts to subscribe to Web Push.

```erb
<%= tag.button "Notifications", data: {
  controller: :notifications,
  action: "notifications#attemptToSubscribe",
  notifications_subscriptions_url_value: push_subscriptions_path,
  notifications_vapid_public_key_value: ActionPushWeb.vapid_identification.fetch(:public_key)
} %>
```

When clicked, this will register the service worker, ask for Notification permission, and make a POST request to `push_subscriptions_path` to store the `PushSubscription` details with Action Push Web.

### Service Worker

The service worker is responsible for receiving Push events and displaying them with the [Notification API](https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API).

It can be used to set the the app badge as well.

## Sending Notifications

You can send notifications to one subscription or many using the pool.

Common arguments for notifications:

- `title` - The title of the notification
- `body` - The main content of the notification
- `path` - A path like `/notifications` to open when the notification is clicked
- `badge` (optional) - Sets the badge on the icon, commonly used for unread message counts
- `icon` (optional) - URL of an icon to be displayed in the notification

See [Notification parameters](https://developer.mozilla.org/en-US/docs/Web/API/Notification/Notification)

### Sending to a single subscription

Using an `ActionPushWeb::Subscription`, you can build a notification and deliver it.

```ruby
push_subscription = Current.user.push_subscriptions.last
push_subscription.notification(
  title: "Hello world",
  body: Random.uuid,
  path: notifications_path,
  badge: 1,
  icon: image_url("logo.png")
).deliver
```

### Sending to many subscriptions

You can send many notifications at once using the Pool. This uses a persistent connection to speed up delivery.

```ruby
push_subscriptions = ActionPushWeb::Subscription.all

ActionPushWeb.queue({
  title: "Hello world",
  body: Random.uuid,
  path: notifications_path,
  badge: 1,
  icon: image_url("logo.png")
}, push_subscriptions)
```

## Debugging
Ensure that your operating system settings allow notifications for your browser.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits
This library is based on [pushpad/web-push](https://github.com/pushpad/web-push)
