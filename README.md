# Action Push Web

Action Push Web is a Rails web push notification gem for PWAs.

## Installation

```bash
bundle add action_push_web
bin/rails g action_push_web:install
bin/rails action_push_web:install:migrations
bin/rails db:migrate
```

Generate a VAPID key:

```bash
bin/rails action_push_web:generate_vapid_key
```

Add the key to your Rails credentials

```yaml
vapid:
  public_key: x
  private_key: y
```

Or environment variables:

- `VAPID_PUBLIC_KEY`
- `VAPID_PRIVATE_KEY`

## Debugging

Ensure that your operating system settings allow notifications for your browser.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
