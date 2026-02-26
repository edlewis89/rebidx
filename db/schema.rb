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

ActiveRecord::Schema[7.1].define(version: 2026_02_24_033202) do
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
    t.bigint "profile_id", null: false
    t.bigint "listing_id", null: false
    t.decimal "amount", default: "0.0"
    t.text "message"
    t.text "terms"
    t.integer "status", default: 0, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "profile_id"], name: "index_bids_on_listing_id_and_profile_id", unique: true
    t.index ["listing_id"], name: "index_bids_on_listing_id"
    t.index ["profile_id"], name: "index_bids_on_profile_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "lead_services", force: :cascade do |t|
    t.bigint "lead_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id", "service_id"], name: "index_lead_services_on_lead_id_and_service_id", unique: true
    t.index ["lead_id"], name: "index_lead_services_on_lead_id"
    t.index ["service_id"], name: "index_lead_services_on_service_id"
  end

  create_table "leads", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.decimal "budget"
    t.integer "status", default: 0, null: false
    t.bigint "user_id", null: false
    t.bigint "property_id"
    t.integer "claimed_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claimed_by"], name: "index_leads_on_claimed_by"
    t.index ["property_id"], name: "index_leads_on_property_id"
    t.index ["user_id"], name: "index_leads_on_user_id"
  end

  create_table "license_types", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "requires_verification", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licenses", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.bigint "license_type_id", null: false
    t.string "license_number"
    t.string "state"
    t.date "expires_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["license_type_id"], name: "index_licenses_on_license_type_id"
    t.index ["profile_id"], name: "index_licenses_on_profile_id"
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
    t.integer "status", default: 0, null: false
    t.decimal "budget"
    t.integer "asking_price"
    t.integer "arv"
    t.integer "estimated_rehab"
    t.integer "estimated_rent"
    t.integer "deal_type"
    t.string "property_condition"
    t.integer "max_purchase_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "search_vector"
    t.string "property_type", default: "single_family", null: false
    t.integer "bid_count", default: 0, null: false
    t.decimal "lowest_bid", precision: 12, scale: 2
    t.integer "bids_count", default: 0, null: false
    t.index ["arv"], name: "index_listings_on_arv"
    t.index ["asking_price"], name: "index_listings_on_asking_price"
    t.index ["bid_count"], name: "index_listings_on_bid_count"
    t.index ["bids_count"], name: "index_listings_on_bids_count"
    t.index ["deal_type"], name: "index_listings_on_deal_type"
    t.index ["listing_type", "deal_type"], name: "index_listings_on_listing_type_and_deal_type"
    t.index ["lowest_bid"], name: "index_listings_on_lowest_bid"
    t.index ["property_id"], name: "index_listings_on_property_id"
    t.index ["property_type"], name: "index_listings_on_property_type"
    t.index ["search_vector"], name: "index_listings_on_search_vector", using: :gin
    t.index ["status"], name: "index_listings_on_status"
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
    t.integer "service_radius", default: 25, null: false
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

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "membership_id", null: false
    t.bigint "listing_id"
    t.integer "amount_cents"
    t.string "currency"
    t.string "stripe_payment_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_payments_on_listing_id"
    t.index ["membership_id"], name: "index_payments_on_membership_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "profile_services", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_profile_services_on_profile_id"
    t.index ["service_id"], name: "index_profile_services_on_service_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "business_name"
    t.integer "profile_type"
    t.boolean "cash_buyer", default: false
    t.string "investment_focus"
    t.string "primary_market"
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "verification_status"
    t.string "full_name"
    t.string "phone_number"
    t.string "tax_id"
    t.string "government_id"
    t.string "business_license_number"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.float "latitude"
    t.float "longitude"
    t.index ["latitude", "longitude"], name: "index_profiles_on_latitude_and_longitude"
    t.index ["profile_type"], name: "index_profiles_on_profile_type"
    t.index ["user_id"], name: "index_profiles_on_user_id"
    t.index ["verification_status"], name: "index_profiles_on_verification_status"
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.string "parcel_number"
    t.integer "sqft"
    t.string "zoning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.index ["latitude", "longitude"], name: "index_properties_on_latitude_and_longitude"
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "rater_id", null: false
    t.bigint "profile_id", null: false
    t.integer "score", null: false
    t.text "review"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bid_id", null: false
    t.index ["bid_id"], name: "index_ratings_on_bid_id"
    t.index ["profile_id"], name: "index_ratings_on_profile_id"
    t.index ["rater_id"], name: "index_ratings_on_rater_id"
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
    t.string "stripe_account_id"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
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
    t.datetime "verified_at"
    t.index ["user_id"], name: "index_verification_profiles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bids", "listings"
  add_foreign_key "bids", "profiles"
  add_foreign_key "lead_services", "leads"
  add_foreign_key "lead_services", "services"
  add_foreign_key "leads", "properties"
  add_foreign_key "leads", "users"
  add_foreign_key "licenses", "license_types"
  add_foreign_key "licenses", "profiles"
  add_foreign_key "listing_services", "listings"
  add_foreign_key "listing_services", "services"
  add_foreign_key "listings", "properties"
  add_foreign_key "listings", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "payments", "listings"
  add_foreign_key "payments", "memberships"
  add_foreign_key "payments", "users"
  add_foreign_key "profile_services", "profiles"
  add_foreign_key "profile_services", "services"
  add_foreign_key "profiles", "users"
  add_foreign_key "properties", "users"
  add_foreign_key "ratings", "bids"
  add_foreign_key "ratings", "profiles"
  add_foreign_key "ratings", "users", column: "rater_id"
  add_foreign_key "subscriptions", "memberships"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "verification_checks", "verification_profiles"
  add_foreign_key "verification_profiles", "users"
end
