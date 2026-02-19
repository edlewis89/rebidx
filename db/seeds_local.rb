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
ProfileService.destroy_all
Profile.destroy_all
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
                       service_radius: 10,  # small radius
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
                       service_radius: 25,  # mid radius
                       features: {
                         max_listings: 10,
                         max_bids_per_month: 10,
                         messaging: true,
                         featured_listings: true,
                         can_bid_high_value: true,
                         bid_range: { low: 0, high: 20_000 }
                       },
                       active: true
                     },
                     {
                       name: "Elite",       # Class B
                       price_cents: 6900,
                       service_radius: 50,  # large radius
                       features: {
                         max_listings: 20,
                         max_bids_per_month: 40,
                         messaging: true,
                         featured_listings: true,
                         can_bid_high_value: true,
                         bid_range: { low: 0, high: 100_000 }
                       },
                       active: true
                     },
                     {
                       name: "Platinum",        # Class A
                       price_cents: 9900,
                       service_radius: 100, # max radius
                       features: {
                         max_listings: 9999,
                         max_bids_per_month: 9999,
                         messaging: true,
                         featured_listings: true,
                         can_bid_high_value: true,
                         priority_support: true,
                         bid_range: { low: 0, high: 1_000_000 } # effectively unlimited
                       },
                       active: true
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
hvac         = Service.create!(name: "HVAC / Heating & Cooling")
landscaping  = Service.create!(name: "Landscaping / Lawn Care")
carpentry    = Service.create!(name: "Carpentry / Woodwork")
flooring     = Service.create!(name: "Flooring")
windows_doors = Service.create!(name: "Window & Door Installation")
pest_control = Service.create!(name: "Pest Control")
appliance    = Service.create!(name: "Appliance Repair")
security     = Service.create!(name: "Security Systems / Smart Home")
masonry      = Service.create!(name: "Masonry / Concrete")
pool_spa     = Service.create!(name: "Pool & Spa Services")
moving       = Service.create!(name: "Moving / Hauling Services")
gutters      = Service.create!(name: "Gutter & Exterior Maintenance")
handyman     = Service.create!(name: "Handyman / General Repairs")
dog_walker   = Service.create!(name: "Dog Walker / Pet Care")

puts "✅ Services seeded"

# ===============================
# SERVICE PROVIDER PROFILES
# ===============================
profile_unlicensed = Profile.create!(
  user: unlicensed_provider,
  profile_type: :service_provider,
  business_name: "Bob Repairs",
  full_name: "Bob Seiger",
  tax_id: "123456789"
)

profile_contractor = Profile.create!(
  user: licensed_contractor,
  profile_type: :service_provider,
  business_name: "Charlie's Construction",
  full_name: "Charlie Sheen",
  tax_id: "987654321"
)

puts "✅ Provider profiles seeded"

# Assign license types
profile_contractor.license_types << class_c
puts "✅ Provider license types assigned"

# # Provider services
# [plumbing, painting, construction].each do |svc|
#   ProviderService.create!(service_provider_profile: profile_unlicensed, service: svc)
# end
# Provider services
[plumbing, painting, construction].each do |svc|
  profile_unlicensed.services << svc
end

# [plumbing, electrical, roofing, construction].each do |svc|
#   ProviderService.create!(service_provider_profile: profile_contractor, service: svc)
# end
[plumbing, electrical, roofing, construction].each do |svc|
  profile_contractor.services << svc
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

Profile.create!(user: homeowner, profile_type: :homeowner, full_name: "Alice Homeowner")
Profile.create!(user: homeowner2, profile_type: :homeowner, full_name: "Eve Homeowner")

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
def create_bid(user, profile, listing, amount, message)
  membership = user.subscription&.membership
  return unless membership

  bid_range = membership.features["bid_range"]
  min = bid_range["low"]
  max = bid_range["high"]
  return if amount < min || amount > max

  Bid.create!(
    listing: listing,
    profile: profile,
    amount: amount,
    message: message,
    status: :pending
  )
end

# Notes:
#   profile.user is used inside the helper if you need the membership for bid limits.
#     Any existing Bid controller logic that expected bid.user will need to be updated to bid.profile.user instead.

# Unlicensed provider: only low-budget
create_bid(unlicensed_provider, profile_unlicensed, listing1, 180, "Quick affordable fix")
create_bid(unlicensed_provider, profile_unlicensed, listing2, 300, "Clean professional job")
create_bid(unlicensed_provider, profile_unlicensed, listing3, 750, "Handled similar framing before")
create_bid(unlicensed_provider, profile_unlicensed, listing4, 900, "Attempt high job — should be blocked by range")

# Licensed contractor: full range
create_bid(licensed_contractor, profile_contractor, listing3, 900, "Licensed, insured, fast turnaround")
create_bid(licensed_contractor, profile_contractor, listing4, 2_200, "Bathroom remodel with permits")
create_bid(licensed_contractor, profile_contractor, listing5, 23_000, "Full crew, inspections included")
# create_bid(licensed_contractor, listing6, 11_500, "Roof replacement with warranty")

# Optional: Pro places bids to hit limit
create_bid(licensed_contractor, profile_contractor, listing7, 280, "Quick plumbing fix")
create_bid(licensed_contractor, profile_contractor, listing8, 400, "Painting with high finish")
# create_bid(licensed_contractor, listing9, 900, "Deck repair by licensed team")
puts "✅ Additional bids by Pro seeded to reach bid limit"


puts "✅ Bids seeded respecting membership ranges"
puts "🎉 SEEDING COMPLETE!"





