class AddShopToBatchInventoryTables < ActiveRecord::Migration[8.1]
  class MigrationShop < ApplicationRecord
    self.table_name = "shops"
  end

  class MigrationProductBatch < ApplicationRecord
    self.table_name = "product_batches"
  end

  class MigrationVariantSetting < ApplicationRecord
    self.table_name = "variant_settings"
  end

  def up
    add_reference :product_batches, :shop, foreign_key: true, null: true, index: true
    add_reference :variant_settings, :shop, foreign_key: true, null: true, index: true

    default_shop_id = MigrationShop.order(:id).pick(:id)

    if default_shop_id.blank? && (MigrationProductBatch.exists? || MigrationVariantSetting.exists?)
      raise ActiveRecord::IrreversibleMigration, "Cannot backfill shop_id without an existing shop record"
    end

    MigrationProductBatch.where(shop_id: nil).update_all(shop_id: default_shop_id) if default_shop_id.present?
    MigrationVariantSetting.where(shop_id: nil).update_all(shop_id: default_shop_id) if default_shop_id.present?

    change_column_null :product_batches, :shop_id, false
    change_column_null :variant_settings, :shop_id, false

    remove_index :variant_settings, :shopify_variant_id if index_exists?(:variant_settings, :shopify_variant_id)

    add_index :product_batches, [:shop_id, :shopify_variant_id], name: "index_product_batches_on_shop_id_and_variant_id"
    add_index :variant_settings, [:shop_id, :shopify_variant_id], unique: true, name: "index_variant_settings_on_shop_id_and_variant_id"
  end

  def down
    remove_index :product_batches, name: "index_product_batches_on_shop_id_and_variant_id"
    remove_index :variant_settings, name: "index_variant_settings_on_shop_id_and_variant_id"
    add_index :variant_settings, :shopify_variant_id, unique: true

    remove_reference :product_batches, :shop, foreign_key: true
    remove_reference :variant_settings, :shop, foreign_key: true
  end
end
