class CreateProductBatches < ActiveRecord::Migration[8.1]
  def change
    create_table :product_batches do |t|
      t.string :shopify_variant_id, null: false
      t.string :batch_number, null: false
      t.date :expiry_date, null: false
      t.integer :quantity, null: false, default: 0
      t.datetime :alert_sent_at

      t.timestamps
    end

    add_index :product_batches, :shopify_variant_id
    add_check_constraint :product_batches, "quantity >= 0", name: "product_batches_quantity_non_negative"
  end
end
