module Inventory
  class ExpiryAlertService
    def initialize(shop:, today: Date.current, logger: Rails.logger)
      @shop = shop
      @today = today
      @logger = logger
    end

    def call
      raise ArgumentError, "shop is required" if shop.blank?

      batches = shop.product_batches.where(alert_sent_at: nil).available_on(today)
      settings = shop.variant_settings.where(shopify_variant_id: batches.distinct.pluck(:shopify_variant_id)).index_by(&:shopify_variant_id)
      alerted_batches = []

      batches.find_each do |batch|
        alert_days = settings[batch.shopify_variant_id]&.expiry_alert_days.to_i
        next unless batch.expiring_soon?(alert_days, today)

        logger.info(
          "Expiry alert for shop=#{shop.shopify_domain} variant=#{batch.shopify_variant_id} batch=#{batch.batch_number} expiry_date=#{batch.expiry_date}"
        )
        batch.update!(alert_sent_at: Time.current)
        alerted_batches << batch
      end

      alerted_batches
    end

    private

    attr_reader :logger, :shop, :today
  end
end
