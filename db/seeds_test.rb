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
Membership.destroy_all
Notification.destroy_all
Subscription.destroy_all

puts "🌱 Seeding data..."

# ===============================
# MEMBERSHIPS
# ===============================
#
# Perfect! That’s a clean, intuitive progression:
#
# Free → basic, Class C, low-value jobs only
#
# Pro → entry paid tier, mid-range jobs (Class C)
#
# Elite → high-tier, higher-value jobs (Class B)
#
# Platinum → top-tier, unlimited/highest-value jobs (Class A)
#
# We can assign bid ranges for each tier like this (adjustable later in admin panel):
#
# Tier	Class	Bid Range (USD)
# Free	C	0 – 2,000
# Pro	C/B	0 – 20,000
# Elite	B	0 – 100,000
# Platinum	A	0 – unlimited
Membership.create!([
         {
           name: "Free",
           price_cents: 0,
           features: {
             max_listings: 5,
             max_bids_per_month: 5,
             messaging: false,
             can_bid_high_value: false,
             show_ads: true,
             featured_listings: false,
             bid_range: { low: 0, high: 1000 } # unlicensed or low-tier
           },
           active: true
         },
          {
            name: "Pro",          # Class C
            price_cents: 2900,
            features: {
              max_listings: 10,
              max_bids_per_month: 10,
              messaging: true,
              featured_listings: true,
              can_bid_high_value: true,
              bid_range: { low: 0, high: 20_000 }
            }
          },
          {
            name: "Elite",       # Class B
            price_cents: 6900,
            features: {
              max_listings: 20,
              max_bids_per_month: 40,
              messaging: true,
              featured_listings: true,
              can_bid_high_value: true,
              bid_range: { low: 0, high: 100_000 }
            }
          },
          {
            name: "Platinum",        # Class A
            price_cents: 9900,
            features: {
              max_listings: 9999,
              max_bids_per_month: 9999,
              messaging: true,
              featured_listings: true,
              can_bid_high_value: true,
              priority_support: true,
              bid_range: { low: 0, high: 1_000_000 } # effectively unlimited
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
# SUBSCRIPTIONS
# ===============================
pro_membership = Membership.find_by(name: "Pro")
licensed_contractor.create_subscription!(membership: pro_membership, status: "active")

puts "✅ Subscriptions seeded"

# ===============================
# SERVICES
# ===============================
plumbing     = Service.create!(name: "Plumbing")
electrical   = Service.create!(name: "Electrical")
painting     = Service.create!(name: "Painting")
roofing      = Service.create!(name: "Roofing")
construction = Service.create!(name: "Construction")
cleaning     = Service.create!(name: "Cleaning Service")
custom       = Service.create!(name: "Custom / Other Service")

puts "✅ Services seeded"

# ===============================
# SERVICE PROVIDER PROFILES
# ===============================
profile_unlicensed = ServiceProviderProfile.create!(
  user: unlicensed_provider,
  business_name: "Bob Repairs",
  full_name: "Bob Seiger",
  tax_id: "123456789"
)

profile_contractor = ServiceProviderProfile.create!(
  user: licensed_contractor,
  business_name: "Charlie's Construction",
  full_name: "Charlie Sheen",
  tax_id: "987654321"
)

puts "✅ Provider profiles seeded"

# Assign license types
profile_contractor.license_types << class_c
puts "✅ Provider license types assigned"

# Provider services
[plumbing, painting, construction].each do |svc|
  ProviderService.create!(service_provider_profile: profile_unlicensed, service: svc)
end

[plumbing, electrical, roofing, construction].each do |svc|
  ProviderService.create!(service_provider_profile: profile_contractor, service: svc)
end

puts "✅ Provider services seeded"

# ===============================
# PROPERTIES
# ===============================
property1 = Property.create!(user: homeowner, title: "Maple Street House", city: "New York", address: "123 Maple St")
property2 = Property.create!(user: homeowner, title: "Oak Avenue Condo", city: "Boston", address: "456 Oak Ave")
property3 = Property.create!(user: homeowner, title: "Tallimore Estates", city: "Chantilly", address: "28 Tallimore Ave")

puts "✅ Properties seeded"

# ===============================
# LISTINGS — mixed values
# ===============================
listing1 = Listing.create!(user: homeowner, property: property1, title: "Fix Kitchen Sink", description: "The sink is leaking badly", listing_type: :service, status: :open, budget: 200)
listing2 = Listing.create!(user: homeowner, property: property2, title: "Paint Living Room", description: "Need fresh paint in living room", listing_type: :service, status: :open, budget: 350)
listing3 = Listing.create!(user: homeowner, property: property2, title: "Shed framing repair", description: "Minor framing and reinforcement work", listing_type: :build_opportunity, status: :open, budget: 850)
listing4 = Listing.create!(user: homeowner, property: property3, title: "Bathroom Remodel", description: "Mid-level bathroom upgrade", listing_type: :build_opportunity, status: :open, budget: 2_500)
listing5 = Listing.create!(user: homeowner, property: property3, title: "Add basement room", description: "Full basement expansion with permits", listing_type: :build_opportunity, status: :open, budget: 24_000)
# listing6 = Listing.create!(user: homeowner, property: property1, title: "Roof Replacement", description: "Full tear-off and new roof install", listing_type: :build_opportunity, status: :open, budget: 12_000)

puts "✅ Listings seeded"

# Listing services
ListingService.create!(listing: listing1, service: plumbing)
ListingService.create!(listing: listing2, service: painting)
ListingService.create!(listing: listing3, service: construction)
ListingService.create!(listing: listing4, service: construction)
ListingService.create!(listing: listing5, service: construction)
# ListingService.create!(listing: listing6, service: roofing)

puts "✅ Listing services linked"


# ===============================
# SECOND HOMEOWNER FOR TESTING
# ===============================
homeowner2 = User.create!(name: "Eve Homeowner", email: "eve@example.com", password: "password", role: :homeowner)
puts "✅ Second homeowner seeded"

# Properties
property4 = Property.create!(user: homeowner2, title: "Cedar Lane House", city: "Chicago", address: "101 Cedar Ln")
property5 = Property.create!(user: homeowner2, title: "Pine Street Apartment", city: "Seattle", address: "202 Pine St")
property6 = Property.create!(user: homeowner2, title: "Birchwood Villa", city: "Austin", address: "303 Birchwood Ave")
puts "✅ Properties for second homeowner seeded"

# Listings — mid-tier so Pro can bid
listing7 = Listing.create!(user: homeowner2, property: property4, title: "Fix Leaky Faucet", description: "Kitchen faucet leaking", listing_type: :service, status: :open, budget: 300)
listing8 = Listing.create!(user: homeowner2, property: property5, title: "Paint Bedroom", description: "Need bedroom painted", listing_type: :service, status: :open, budget: 450)
# listing9 = Listing.create!(user: homeowner2, property: property6, title: "Small Deck Repair", description: "Minor deck repair needed", listing_type: :build_opportunity, status: :open, budget: 950)
puts "✅ Listings for second homeowner seeded"

# Listing Services
ListingService.create!(listing: listing7, service: plumbing)
ListingService.create!(listing: listing8, service: painting)
# ListingService.create!(listing: listing9, service: construction)
puts "✅ Listing services linked for second homeowner"


# ===============================
# BIDS — respect membership bid ranges
# ===============================
def create_bid(user, listing, amount, message)
  min, max = user.bid_range
  return if amount < min || amount > max

  bid = Bid.create(
    listing: listing,
    user: user,
    amount: amount,
    message: message,
    status: :pending
  )

  if bid.valid?
    puts "Created bid"
  else
    puts "Failed to create #{ bid.inspect } #{bid.errors.inspect}"
  end
end

# Unlicensed provider: only low-budget
create_bid(unlicensed_provider, listing1, 180, "Quick affordable fix")
create_bid(unlicensed_provider, listing2, 300, "Clean professional job")
create_bid(unlicensed_provider, listing3, 750, "Handled similar framing before")
create_bid(unlicensed_provider, listing4, 900, "Attempt high job — should be blocked by range")

# Licensed contractor: full range
create_bid(licensed_contractor, listing3, 900, "Licensed, insured, fast turnaround")
create_bid(licensed_contractor, listing4, 2_200, "Bathroom remodel with permits")
create_bid(licensed_contractor, listing5, 23_000, "Full crew, inspections included")
# create_bid(licensed_contractor, listing6, 11_500, "Roof replacement with warranty")

# Optional: Pro places bids to hit limit
create_bid(licensed_contractor, listing7, 280, "Quick plumbing fix")
create_bid(licensed_contractor, listing8, 400, "Painting with high finish")
# create_bid(licensed_contractor, listing9, 900, "Deck repair by licensed team")
puts "✅ Additional bids by Pro seeded to reach bid limit"


puts "✅ Bids seeded respecting membership ranges"
puts "🎉 SEEDING COMPLETE!"



#
#
# # ===============================
# #   LISTINGS (EXPANDED FOR TESTING)
# # ===============================
#
# listing1 = Listing.create!(user: homeowner, property: property1, title: "Fix Kitchen Sink", description: "The sink is leaking badly", listing_type: :service, status: :open, budget: 200)
# listing2 = Listing.create!(user: homeowner, property: property2, title: "Paint Living Room", description: "Need fresh paint in living room", listing_type: :service, status: :open, budget: 350)
# listing3 = Listing.create!(user: homeowner, property: property2, title: "Shed framing repair", description: "Minor framing and reinforcement work", listing_type: :build_opportunity, status: :open, budget: 850)
#
# # Medium jobs (unlicensed allowed)
# listing4 = Listing.create!(user: homeowner, property: property1, title: "Replace Bathroom Vanity", description: "Install new vanity and plumbing", listing_type: :service, status: :open, budget: 600)
# listing5 = Listing.create!(user: homeowner, property: property3, title: "Deck Repair", description: "Fix loose boards and supports", listing_type: :service, status: :open, budget: 950)
#
# # High-value jobs (LICENSE REQUIRED)
# listing6 = Listing.create!(user: homeowner, property: property3, title: "Kitchen Remodel", description: "Full remodel with permits", listing_type: :build_opportunity, status: :open, budget: 2_500)
# listing7 = Listing.create!(user: homeowner, property: property2, title: "Roof Replacement", description: "Full roof tear-off and replacement", listing_type: :service, status: :open, budget: 8_000)
# listing8 = Listing.create!(user: homeowner, property: property3, title: "Basement Expansion", description: "New basement room + inspection", listing_type: :build_opportunity, status: :open, budget: 24_000)
#
# puts "✅ Listings seeded (low, medium, high value)"
#
# # ===============================
# # LISTING SERVICES
# # ===============================
# ListingService.create!(listing: listing1, service: plumbing)
# ListingService.create!(listing: listing2, service: painting)
# ListingService.create!(listing: listing3, service: construction)
#
# ListingService.create!(listing: listing4, service: plumbing)
# ListingService.create!(listing: listing5, service: construction)
#
# ListingService.create!(listing: listing6, service: construction)
# ListingService.create!(listing: listing7, service: roofing)
# ListingService.create!(listing: listing8, service: construction)
#
# puts "✅ Listing services linked"
#
# # -------------------------------
# # UNLICENSED PROVIDER (Bob)
# # -------------------------------
#
# # Allowed bids (under $1000)
# Bid.create!(listing: listing1, user: unlicensed_provider, amount: 180, message: "Fast fix", status: :pending)
# Bid.create!(listing: listing2, user: unlicensed_provider, amount: 300, message: "Quality paint job", status: :pending)
# Bid.create!(listing: listing3, user: unlicensed_provider, amount: 800, message: "Handled similar framing", status: :pending)
# Bid.create!(listing: listing4, user: unlicensed_provider, amount: 550, message: "Can install vanity", status: :pending)
# Bid.create!(listing: listing5, user: unlicensed_provider, amount: 900, message: "Deck repair specialist", status: :pending)
#
# # ❌ DO NOT seed illegal bids on high-value jobs — let UI test block instead
# puts "✅ Unlicensed provider seeded with valid bids"
#
# # -------------------------------
# # LICENSED PROVIDER (Charlie)
# # -------------------------------
#
# Bid.create!(listing: listing3, user: licensed_contractor, amount: 875, message: "Licensed & insured", status: :pending)
# Bid.create!(listing: listing6, user: licensed_contractor, amount: 2_300, message: "Kitchen remodel pros", status: :pending)
# Bid.create!(listing: listing7, user: licensed_contractor, amount: 7_500, message: "Roofing crew ready", status: :pending)
# Bid.create!(listing: listing8, user: licensed_contractor, amount: 23_000, message: "Full basement build + permits", status: :pending)
#
# puts "✅ Licensed contractor seeded with high-value bids"


# # ===============================
# # BIDS
# # ===============================
# # Handyman bids (ALLOWED)
# Bid.create!(
#   listing: listing1,
#   user: unlicensed_provider,
#   amount: 180,
#   message: "Can fix this in 2 hours",
#   status: :pending
# )
#
# Bid.create!(
#   listing: listing2,
#   user: unlicensed_provider,
#   amount: 320,
#   message: "Professional painting, clean finish",
#   status: :pending
# )
#
# Bid.create!(
#   listing: listing3,
#   user: unlicensed_provider,
#   amount: 800,
#   message: "Handled similar framing jobs before",
#   status: :pending
# )
#
# # Contractor bids
# Bid.create!(
#   listing: listing3,
#   user: licensed_contractor,
#   amount: 900,
#   message: "Licensed contractor, insured work",
#   status: :pending
# )
#

# Bid.create!(
#   listing: listing4,
#   user: licensed_contractor,
#   amount: 23000,
#   message: "Full crew, permits and inspections included",
#   status: :pending
# )

# puts "✅ Bids seeded"
#
# puts "🎉 SEEDING COMPLETE!"





