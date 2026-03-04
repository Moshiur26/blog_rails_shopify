class AppUninstalledJob < ApplicationJob
  queue_as :default

  def perform(shop_domain, webhook_id)
    shop = Shop.find_by(shopify_domain: shop_domain)
    return unless shop

    ActiveRecord::Base.transaction do
      shop.update!(
        access_token: nil,
        installed: false,
        uninstalled_at: Time.current
      )

      ProcessedWebhook.create!(webhook_id: webhook_id)
    end

    Rails.logger.info "App uninstalled for #{shop_domain}"
  end
end
