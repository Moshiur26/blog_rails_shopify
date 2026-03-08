# frozen_string_literal: true

class ProductsController < AuthenticatedController
  def index
    products = ShopifyAPI::Product.all(limit: 10)
    payload = products.map { |product| serialize_product(product) }

    render(json: { products: payload })
  end

  def qr_code
    product = ShopifyAPI::Product.find(id: params[:id])
    handle = product.handle.to_s

    return head :unprocessable_entity if handle.blank?

    product_url = "https://#{shop_domain}/products/#{handle}"
    svg = ProductQrCodeBuilder.svg_for_url(product_url)

    render plain: svg, content_type: "image/svg+xml"
  rescue StandardError
    head :not_found
  end

  private

  def serialize_product(product)
    {
      id: product.id,
      title: product.title,
      handle: product.handle
    }
  end

  def shop_domain
    @current_shopify_session&.shop || params[:shop].to_s
  end
end
