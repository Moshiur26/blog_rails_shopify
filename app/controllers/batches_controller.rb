# frozen_string_literal: true

class BatchesController < AuthenticatedController
  before_action :set_product_batch, only: [:edit, :update, :destroy]

  def index
    @variant_id = params[:variant_id].presence
    @batches = ProductBatch.order(:expiry_date, :created_at)
    @batches = @batches.for_variant(@variant_id) if @variant_id.present?
    @settings_by_variant = VariantSetting.where(shopify_variant_id: @batches.map(&:shopify_variant_id).uniq).index_by(&:shopify_variant_id)
  end

  def new
    @product_batch = ProductBatch.new(shopify_variant_id: params[:variant_id].presence)
    redirect_to batches_path, alert: "Variant ID is required to create a batch." if @product_batch.shopify_variant_id.blank?
  end

  def create
    @product_batch = ProductBatch.new(product_batch_params)

    if @product_batch.save
      sync_variant_inventory(@product_batch.shopify_variant_id)
      redirect_to batches_path(variant_id: @product_batch.shopify_variant_id), notice: "Batch created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @product_batch.update(product_batch_params)
      sync_variant_inventory(@product_batch.shopify_variant_id)
      redirect_to batches_path(variant_id: @product_batch.shopify_variant_id), notice: "Batch updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    variant_id = @product_batch.shopify_variant_id
    @product_batch.destroy!
    sync_variant_inventory(variant_id)

    redirect_to batches_path(variant_id: variant_id), notice: "Batch deleted."
  end

  private

  def set_product_batch
    @product_batch = ProductBatch.find(params[:id])
  end

  def product_batch_params
    params.require(:product_batch).permit(:shopify_variant_id, :batch_number, :expiry_date, :quantity)
  end

  def sync_variant_inventory(variant_id)
    Shopify::InventorySync.new(shop: current_shop_record, variant_ids: [variant_id]).call
  rescue Shopify::InventorySync::SyncError => e
    flash[:alert] = "Batch saved, but Shopify inventory sync failed: #{e.message}"
  end
end
