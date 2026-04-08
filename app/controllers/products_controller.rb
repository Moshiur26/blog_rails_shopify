# frozen_string_literal: true

class ProductsController < AuthenticatedController
  def index
    limit = params[:limit].to_i
    limit = 12 if limit <= 0 || limit > 250
    page_info = params[:page_info].presence

    query = { limit: limit }
    query[:page_info] = page_info if page_info.present?
    products = ShopifyAPI::Product.all(**query)
    payload = products.map { |product| serialize_product(product) }
    if ShopifyAPI::Product.respond_to?(:next_page_info)
      @next_page_info = ShopifyAPI::Product.next_page_info
      @prev_page_info = ShopifyAPI::Product.previous_page_info if ShopifyAPI::Product.respond_to?(:previous_page_info)
      @prev_page_info ||= ShopifyAPI::Product.prev_page_info if ShopifyAPI::Product.respond_to?(:prev_page_info)
    else
      @next_page_info = products.next_page_info if products.respond_to?(:next_page_info)
      @prev_page_info = products.previous_page_info if products.respond_to?(:previous_page_info)
      @prev_page_info ||= products.prev_page_info if products.respond_to?(:prev_page_info)
    end
    @page_limit = limit
    @bootstrap_data = {
      shopOrigin: shop_domain,
      host: params[:host],
      products: payload,
      nextPageInfo: @next_page_info,
      previousPageInfo: @prev_page_info,
      pageLimit: @page_limit
    }

    respond_to do |format|
      format.html { render :index }
      format.json do
        render json: {
          products: payload,
          next_page_info: @next_page_info,
          previous_page_info: @prev_page_info,
          page_limit: @page_limit
        }
      end
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
    image = product.image
    image ||= product.images&.first if product.respond_to?(:images)
    image_url = image&.dig("src") || image&.dig(:src)
    primary_variant = product.variants&.first
    {
      id: product.id,
      title: product.title,
      handle: product.handle,
      image_url: image_url,
      primary_variant_id: primary_variant&.dig("id") || primary_variant&.dig(:id)
    }
  end

  def shop_domain
    @current_shopify_session&.shop || params[:shop].to_s
  end
end
