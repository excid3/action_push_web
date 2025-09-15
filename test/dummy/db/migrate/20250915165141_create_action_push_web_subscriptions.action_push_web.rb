# This migration comes from action_push_web (originally 20250915164238)
class CreateActionPushWebSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :action_push_web_subscriptions do |t|
      t.belongs_to :user, polymorphic: true, null: false
      t.string :endpoint
      t.string :p256dh_key
      t.string :auth_key
      t.string :user_agent

      t.timestamps
    end

    add_index :action_push_web_subscriptions, [ :endpoint, :p256dh_key, :auth_key ]
  end
end
