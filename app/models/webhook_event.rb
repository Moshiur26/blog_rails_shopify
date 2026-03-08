class WebhookEvent < ApplicationRecord
  validates :topic, presence: true
  validates :shop_domain, presence: true
  validates :webhook_id, presence: true, uniqueness: true
  validates :payload, presence: true
  validates :received_at, presence: true
end
