# frozen_string_literal: true

class VariantSettingsController < AuthenticatedController
  before_action :set_variant_setting

  def edit; end

  def update
    @variant_setting.assign_attributes(variant_setting_params)

    if @variant_setting.save
      redirect_to edit_variant_setting_path(@variant_setting.shopify_variant_id, app_context_params), notice: "Expiry alert settings updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_variant_setting
    @variant_setting = current_shop.variant_settings.find_or_initialize_by(shopify_variant_id: params[:id].to_s)
  end

  def variant_setting_params
    params.require(:variant_setting).permit(:expiry_alert_days).merge(
      shop: current_shop,
      shopify_variant_id: params[:id].to_s
    )
  end
end
