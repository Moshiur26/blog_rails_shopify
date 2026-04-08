class VariantSetting < ApplicationRecord
  validates :shopify_variant_id, presence: true, uniqueness: true
  validates :expiry_alert_days, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def self.for_variant(variant_id)
    find_or_initialize_by(shopify_variant_id: variant_id.to_s)
  end
end
