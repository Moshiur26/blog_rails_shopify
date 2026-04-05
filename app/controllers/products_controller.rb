# frozen_string_literal: true

class ProductsController < AuthenticatedController
  def index
    products = ShopifyAPI::Product.all(limit: 10)
    payload = products.map { |product| serialize_product(product) }
    @bootstrap_data = {
      shopOrigin: shop_domain,
      host: params[:host],
      products: payload
    }

    respond_to do |format|
      format.html { render :index }
      format.json { render json: { products: payload } }
    end
  end

  def qr_code
    product = ShopifyAPI::Product.find(id: params[:id])
    handle = product.handle.to_s

    return head :unprocessable_entity if handle.blank?

    @product_title = product.title
    @product_handle = handle
    @product_url = "https://#{shop_domain}/products/#{handle}"
    @qr_svg = ProductQrCodeBuilder.svg_for_url(@product_url)

    respond_to do |format|
      format.html { render :qr_code }
      format.svg { render plain: @qr_svg, content_type: "image/svg+xml" }
    end
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
