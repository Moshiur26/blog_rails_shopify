# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  include ShopifyApp::EnsureHasSession
  before_action :ensure_current_shop_record!

  helper_method :current_shop_record

  private

  def current_shop_record
    @current_shop_record ||= Shop.find_by(shopify_domain: @current_shopify_session&.shop || params[:shop].to_s)
  end

  def ensure_current_shop_record!
    return if current_shop_record.present?

    head :not_found
  end
end
