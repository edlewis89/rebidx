# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Clear existing data
# db/seeds.rb

# ===============================
# CLEAN SLATE
# ===============================
Bid.destroy_all
ListingService.destroy_all
Listing.destroy_all
Property.destroy_all
ProviderService.destroy_all
ServiceProviderProfile.destroy_all
Service.destroy_all
LicenseType.destroy_all
User.destroy_all

puts "🌱 Seeding data..."

# ===============================
# MEMBERSHIPS
# ===============================
# features: {
#   max_listings: 5,
#   max_bids_per_month: 5,
#   messaging: false,
#   can_bid_high_value: false,
#   requires_verification: true,
#   show_ads: true,
#   featured_listings: false
# }
Membership.create!([
                     {
                       name: "Free",
                       price_cents: 0,
                       features: {
                         max_listings: 5,
                         max_bids_per_month: 5,
                         messaging: false,
                         can_bid_high_value: false,
                         requires_verification: true,
                         show_ads: true
                       }
                     },
                     {
                       name: "Pro",
                       price_cents: 2900,
                       features: {
                         max_listings: 10,
                         max_bids_per_month: 20,
                         messaging: true,
                         can_bid_high_value: true,
                         requires_verification: false,
                         featured_listings: true,
                         show_ads: false
                       }
                     },
                     {
                       name: "Elite",
                       price_cents: 9900,
                       features: {
                         max_listings: 999,
                         max_bids_per_month: 999,
                         messaging: true,
                         can_bid_high_value: true,
                         priority_support: true,
                         featured_listings: true,
                         show_ads: false
                       }
                     }
                   ])
puts "✅ Memberships seeded"

# ===============================
# LICENSE TYPES
# ===============================
class_a = LicenseType.create!(name: "Class A", description: "High-rise & large commercial. Full verification required.", requires_verification: true)
class_b = LicenseType.create!(name: "Class B", description: "Mid-size residential & commercial.", requires_verification: true)
class_c = LicenseType.create!(name: "Class C", description: "Small residential & light construction.", requires_verification: true)
puts "✅ License types seeded"

# ===============================
# USERS
# ===============================
homeowner = User.create!(name: "Alice Homeowner", email: "alice@example.com", password: "password", role: :homeowner)
unlicensed_provider = User.create!(name: "Bob Repairs", email: "bob@example.com", password: "password", role: :service_provider)
licensed_contractor = User.create!(name: "Charlie Contractor", email: "pro@example.com", password: "password", role: :service_provider)
admin = User.create!(name: "Admin User", email: "admin@example.com", password: "password", role: :rebidx_admin)
puts "✅ Users seeded"

# ===============================
# SERVICES
# ===============================
plumbing     = Service.create!(name: "Plumbing")
electrical   = Service.create!(name: "Electrical")
painting     = Service.create!(name: "Painting")
roofing      = Service.create!(name: "Roofing")
construction = Service.create!(name: "Construction")
cleaning     = Service.create!(name: "Cleaning Service")
puts "✅ Services seeded"

# ===============================
# SERVICE PROVIDER PROFILES
# ===============================
# Unlicensed provider = "handyman" fallback
profile_unlicensed = ServiceProviderProfile.create!(
  user: unlicensed_provider,
  business_name: "Bob Repairs",
  full_name: "Bob Seiger",
  tax_id: "123456789"
)

# Licensed provider
profile_contractor = ServiceProviderProfile.create!(
  user: licensed_contractor,
  business_name: "Charlie's Construction",
  full_name: "Charlie Sheen",
  tax_id: "987654321"
)
puts "✅ Provider profiles seeded"

# ===============================
# ASSIGN LICENSE TYPES
# ===============================
profile_contractor.license_types << class_c
# Unlicensed provider intentionally left without a license
puts "✅ Provider license types seeded"

# ===============================
# PROVIDER SERVICES
# ===============================
# Unlicensed provider: small jobs only
ProviderService.create!(service_provider_profile: profile_unlicensed, service: plumbing)
ProviderService.create!(service_provider_profile: profile_unlicensed, service: painting)
ProviderService.create!(service_provider_profile: profile_unlicensed, service: construction)

# Licensed contractor: full scope
ProviderService.create!(service_provider_profile: profile_contractor, service: plumbing)
ProviderService.create!(service_provider_profile: profile_contractor, service: electrical)
ProviderService.create!(service_provider_profile: profile_contractor, service: roofing)
ProviderService.create!(service_provider_profile: profile_contractor, service: construction)
puts "✅ Provider services seeded"

# ===============================
# PROPERTIES
# ===============================
property1 = Property.create!(user: homeowner, title: "Maple Street House", city: "New York", address: "123 Maple St")
property2 = Property.create!(user: homeowner, title: "Oak Avenue Condo", city: "Boston", address: "456 Oak Ave")
property3 = Property.create!(user: homeowner, title: "Tallimore Estates", city: "Chantilly", address: "28 Tallimore Ave")
puts "✅ Properties seeded"

# ===============================
# LISTINGS
# ===============================
listing1 = Listing.create!(user: homeowner, property: property1, title: "Fix Kitchen Sink", description: "The sink is leaking badly", listing_type: :service, status: :open, budget: 200)
listing2 = Listing.create!(user: homeowner, property: property2, title: "Paint Living Room", description: "Need fresh paint in living room", listing_type: :service, status: :open, budget: 350)
listing3 = Listing.create!(user: homeowner, property: property2, title: "Shed framing repair", description: "Minor framing and reinforcement work", listing_type: :build_opportunity, status: :open, budget: 850)
listing4 = Listing.create!(user: homeowner, property: property3, title: "Add basement room", description: "Full basement expansion with permits", listing_type: :build_opportunity, status: :open, budget: 24_000)
puts "✅ Listings seeded"

# ===============================
# LISTING SERVICES
# ===============================
ListingService.create!(listing: listing1, service: plumbing)
ListingService.create!(listing: listing2, service: painting)
ListingService.create!(listing: listing3, service: construction)
ListingService.create!(listing: listing4, service: construction)
puts "✅ Listing services linked"

# ===============================
# BIDS
# ===============================
# Example bids (optional)
# Bid.create!(listing: listing1, user: unlicensed_provider, amount: 180, message: "Quick fix", status: :pending)
# Bid.create!(listing: listing3, user: licensed_contractor, amount: 23_000, message: "Full crew and permits", status: :pending)


# ===============================
# BIDS
# ===============================
# Handyman bids (ALLOWED)
# Bid.create!(
#   listing: listing1,
#   user: handyman,
#   amount: 180,
#   message: "Can fix this in 2 hours",
#   status: :pending
# )
#
# Bid.create!(
#   listing: listing2,
#   user: handyman,
#   amount: 320,
#   message: "Professional painting, clean finish",
#   status: :pending
# )
#
# Bid.create!(
#   listing: listing3,
#   user: handyman,
#   amount: 800,
#   message: "Handled similar framing jobs before",
#   status: :pending
# )

# Contractor bids
# Bid.create!(
#   listing: listing3,
#   user: contractor,
#   amount: 900,
#   message: "Licensed contractor, insured work",
#   status: :pending
# )
#
# Bid.create!(
#   listing: listing4,
#   user: contractor,
#   amount: 23000,
#   message: "Full crew, permits and inspections included",
#   status: :pending
# )

puts "✅ Bids seeded"

puts "🎉 SEEDING COMPLETE!"





