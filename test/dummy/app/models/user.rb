class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :push_subscriptions, class_name: "ActionPushWeb::Subscription", dependent: :delete_all

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
