class CreateProcessedWebhooks < ActiveRecord::Migration[8.1]
  def change
    create_table :processed_webhooks do |t|
      t.string :webhook_id, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
