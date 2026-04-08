class CreateVariantSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :variant_settings do |t|
      t.string :shopify_variant_id, null: false
      t.integer :expiry_alert_days, null: false, default: 0

      t.timestamps
    end

    add_index :variant_settings, :shopify_variant_id, unique: true
    add_check_constraint :variant_settings, "expiry_alert_days >= 0", name: "variant_settings_expiry_alert_days_non_negative"
  end
end
