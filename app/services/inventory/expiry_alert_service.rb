module Inventory
  class ExpiryAlertService
    def initialize(today: Date.current, logger: Rails.logger)
      @today = today
      @logger = logger
    end

    def call
      batches = ProductBatch.where(alert_sent_at: nil).available_on(today)
      settings = VariantSetting.where(shopify_variant_id: batches.distinct.pluck(:shopify_variant_id)).index_by(&:shopify_variant_id)
      alerted_batches = []

      batches.find_each do |batch|
        alert_days = settings[batch.shopify_variant_id]&.expiry_alert_days.to_i
        next unless batch.expiring_soon?(alert_days, today)

        logger.info(
          "Expiry alert for variant=#{batch.shopify_variant_id} batch=#{batch.batch_number} expiry_date=#{batch.expiry_date}"
        )
        batch.update!(alert_sent_at: Time.current)
        alerted_batches << batch
      end

      alerted_batches
    end

    private

    attr_reader :logger, :today
  end
end
