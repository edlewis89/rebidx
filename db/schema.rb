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

ActiveRecord::Schema[7.1].define(version: 2026_01_31_205635) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "advertisements", force: :cascade do |t|
    t.string "title"
    t.string "image"
    t.string "url"
    t.boolean "active"
    t.date "start_date"
    t.date "end_date"
    t.integer "placement", default: 0, null: false
    t.string "link", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bids", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "listing_id", null: false
    t.decimal "amount", default: "0.0"
    t.text "message"
    t.text "terms"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_bids_on_listing_id"
    t.index ["user_id"], name: "index_bids_on_user_id"
  end

  create_table "license_types", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "requires_verification", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "listing_services", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_listing_services_on_listing_id"
    t.index ["service_id"], name: "index_listing_services_on_service_id"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "property_id", null: false
    t.string "title"
    t.text "description"
    t.integer "listing_type"
    t.string "status"
    t.decimal "budget"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_listings_on_property_id"
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price_cents", default: 0
    t.string "billing_interval", default: "monthly"
    t.jsonb "features", default: {}
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "body"
    t.string "notification_type"
    t.datetime "read_at"
    t.string "url"
    t.jsonb "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "address"
    t.string "city"
    t.integer "zipcode"
    t.string "parcel_number"
    t.integer "sqft"
    t.string "zoning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "provider_services", force: :cascade do |t|
    t.bigint "service_provider_profile_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_provider_services_on_service_id"
    t.index ["service_provider_profile_id"], name: "index_provider_services_on_service_provider_profile_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "service_provider_profile_id", null: false
    t.integer "score"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bid_id", null: false
    t.index ["bid_id"], name: "index_ratings_on_bid_id"
    t.index ["service_provider_profile_id"], name: "index_ratings_on_service_provider_profile_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "service_provider_licenses", force: :cascade do |t|
    t.bigint "service_provider_profile_id", null: false
    t.bigint "license_type_id", null: false
    t.string "license_number"
    t.string "state"
    t.date "expires_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["license_type_id"], name: "index_service_provider_licenses_on_license_type_id"
    t.index ["service_provider_profile_id"], name: "index_service_provider_licenses_on_service_provider_profile_id"
  end

  create_table "service_provider_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "business_name"
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "verification_status"
    t.string "full_name"
    t.string "phone_number"
    t.string "tax_id"
    t.string "government_id"
    t.string "business_license_number"
    t.index ["user_id"], name: "index_service_provider_profiles_on_user_id"
    t.index ["verification_status"], name: "index_service_provider_profiles_on_verification_status"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "membership_id", null: false
    t.string "status", default: "active"
    t.datetime "current_period_end"
    t.string "stripe_subscription_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id"], name: "index_subscriptions_on_membership_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.integer "role", default: 0, null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "email_verified_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "verification_checks", force: :cascade do |t|
    t.bigint "verification_profile_id", null: false
    t.string "kind"
    t.string "status"
    t.string "provider"
    t.jsonb "data"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["verification_profile_id"], name: "index_verification_checks_on_verification_profile_id"
  end

  create_table "verification_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "status"
    t.integer "trust_score"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_verification_profiles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bids", "listings"
  add_foreign_key "bids", "users"
  add_foreign_key "listing_services", "listings"
  add_foreign_key "listing_services", "services"
  add_foreign_key "listings", "properties"
  add_foreign_key "listings", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "properties", "users"
  add_foreign_key "provider_services", "service_provider_profiles"
  add_foreign_key "provider_services", "services"
  add_foreign_key "ratings", "bids"
  add_foreign_key "ratings", "service_provider_profiles"
  add_foreign_key "ratings", "users"
  add_foreign_key "service_provider_licenses", "license_types"
  add_foreign_key "service_provider_licenses", "service_provider_profiles"
  add_foreign_key "service_provider_profiles", "users"
  add_foreign_key "subscriptions", "memberships"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "verification_checks", "verification_profiles"
  add_foreign_key "verification_profiles", "users"
end
