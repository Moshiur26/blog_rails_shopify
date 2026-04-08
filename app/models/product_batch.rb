class ProductBatch < ApplicationRecord
  scope :for_variant, ->(variant_id) { where(shopify_variant_id: variant_id.to_s) }
  scope :available_on, ->(date = Date.current) { where("expiry_date >= ?", date) }

  validates :shopify_variant_id, presence: true
  validates :batch_number, presence: true
  validates :expiry_date, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def expired?(date = Date.current)
    expiry_date.present? && expiry_date < date
  end

  def alert_date(alert_days)
    return if expiry_date.blank?

    expiry_date - alert_days.to_i.days
  end

  def expiring_soon?(alert_days, date = Date.current)
    return false if expired?(date) || expiry_date.blank?

    date >= alert_date(alert_days)
  end
end
