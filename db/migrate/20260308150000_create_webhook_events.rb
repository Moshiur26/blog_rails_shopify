class CreateWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_events do |t|
      t.string :topic, null: false
      t.string :shop_domain, null: false
      t.string :webhook_id, null: false
      t.jsonb :payload, null: false, default: {}
      t.datetime :received_at, null: false

      t.timestamps
    end

    add_index :webhook_events, :webhook_id, unique: true
    add_index :webhook_events, [:topic, :shop_domain]
  end
end
