# frozen_string_literal: true

class VariantSettingsController < AuthenticatedController
  before_action :set_variant_setting

  def edit; end

  def update
    if @variant_setting.update(variant_setting_params)
      redirect_to batches_path({ variant_id: @variant_setting.shopify_variant_id }.merge(app_context_params)), notice: "Expiry alert settings updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_variant_setting
    @variant_setting = VariantSetting.for_variant(shop: current_shop, variant_id: params[:id])
  end

  def variant_setting_params
    params.require(:variant_setting).permit(:expiry_alert_days).merge(shopify_variant_id: params[:id].to_s)
  end
end
