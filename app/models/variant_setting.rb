class VariantSetting < ApplicationRecord
  belongs_to :shop

  validates :shop, presence: true
  validates :shopify_variant_id, presence: true, uniqueness: { scope: :shop_id }
  validates :expiry_alert_days, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def self.for_variant(shop:, variant_id:)
    shop.variant_settings.find_or_initialize_by(shopify_variant_id: variant_id.to_s)
  end
end
