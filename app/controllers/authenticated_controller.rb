# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  include ShopifyApp::EnsureHasSession

  private

  def current_shop_record
    @current_shop_record ||= Shop.find_by(shopify_domain: @current_shopify_session&.shop || params[:shop].to_s)
  end
end
