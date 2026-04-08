# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_08_110000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "processed_webhooks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "webhook_id", null: false
    t.index ["webhook_id"], name: "index_processed_webhooks_on_webhook_id", unique: true
  end

  create_table "product_batches", force: :cascade do |t|
    t.datetime "alert_sent_at"
    t.string "batch_number", null: false
    t.datetime "created_at", null: false
    t.date "expiry_date", null: false
    t.integer "quantity", default: 0, null: false
    t.bigint "shop_id", null: false
    t.string "shopify_variant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id", "shopify_variant_id"], name: "index_product_batches_on_shop_id_and_variant_id"
    t.index ["shop_id"], name: "index_product_batches_on_shop_id"
    t.index ["shopify_variant_id"], name: "index_product_batches_on_shopify_variant_id"
    t.check_constraint "quantity >= 0", name: "product_batches_quantity_non_negative"
  end

  create_table "shops", force: :cascade do |t|
    t.string "access_scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.boolean "installed", default: true
    t.string "refresh_token"
    t.datetime "refresh_token_expires_at"
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "uninstalled_at"
    t.datetime "updated_at", null: false
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

  create_table "variant_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "expiry_alert_days", default: 0, null: false
    t.bigint "shop_id", null: false
    t.string "shopify_variant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id", "shopify_variant_id"], name: "index_variant_settings_on_shop_id_and_variant_id", unique: true
    t.index ["shop_id"], name: "index_variant_settings_on_shop_id"
    t.check_constraint "expiry_alert_days >= 0", name: "variant_settings_expiry_alert_days_non_negative"
  end

  create_table "webhook_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "received_at", null: false
    t.string "shop_domain", null: false
    t.string "topic", null: false
    t.datetime "updated_at", null: false
    t.string "webhook_id", null: false
    t.index ["topic", "shop_domain"], name: "index_webhook_events_on_topic_and_shop_domain"
    t.index ["webhook_id"], name: "index_webhook_events_on_webhook_id", unique: true
  end

  add_foreign_key "product_batches", "shops"
  add_foreign_key "variant_settings", "shops"
end
