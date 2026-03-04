class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def app_uninstalled
    return head :unauthorized unless valid_webhook?

    shop_domain = request.headers["X-Shopify-Shop-Domain"]
    webhook_id  = request.headers["X-Shopify-Webhook-Id"]

    # Idempotency check
    return head :ok if ProcessedWebhook.exists?(webhook_id: webhook_id)

    AppUninstalledJob.perform_later(shop_domain, webhook_id)

    head :ok
  end

  private

  def valid_webhook?
    hmac_header = request.headers["X-Shopify-Hmac-Sha256"]
    body = request.raw_post

    digest  = OpenSSL::Digest.new("sha256")
    secret  = ENV["SHOPIFY_API_SECRET"]

    calculated_hmac = Base64.strict_encode64(
      OpenSSL::HMAC.digest(digest, secret, body)
    )

    ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, hmac_header)
  end
end
