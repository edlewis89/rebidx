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
                     { name: "Free", price_cents: 0, service_radius: 10, features: { max_listings: 5, max_bids_per_month: 5, messaging: false, can_bid_high_value: false, show_ads: true, featured_listings: false, bid_range: { low: 0, high: 1000 } }, active: true },
                     { name: "Pro", price_cents: 2900, service_radius: 25, features: { max_listings: 10, max_bids_per_month: 10, messaging: true, featured_listings: true, can_bid_high_value: true, bid_range: { low: 0, high: 20_000 } }, active: true },
                     { name: "Elite", price_cents: 6900, service_radius: 50, features: { max_listings: 20, max_bids_per_month: 40, messaging: true, featured_listings: true, can_bid_high_value: true, bid_range: { low: 0, high: 100_000 } }, active: true },
                     { name: "Platinum", price_cents: 9900, service_radius: 100, features: { max_listings: 9999, max_bids_per_month: 9999, messaging: true, featured_listings: true, can_bid_high_value: true, priority_support: true, bid_range: { low: 0, high: 1_000_000 } }, active: true }
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
homeowner1 = User.create!(name: "Alice Homeowner", email: "alice@example.com", password: "password", role: :homeowner)
homeowner2 = User.create!(name: "Eve Homeowner", email: "eve@example.com", password: "password", role: :homeowner)
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
# PROFILES
# ===============================
# Homeowners
profile_homeowner1 = Profile.create!(user: homeowner1, profile_type: :homeowner, full_name: "Alice Homeowner")
profile_homeowner2 = Profile.create!(user: homeowner2, profile_type: :homeowner, full_name: "Eve Homeowner")

# Service providers
profile_unlicensed = Profile.create!(user: unlicensed_provider, profile_type: :service_provider, business_name: "Bob Repairs", full_name: "Bob Seiger", tax_id: "123456789")
profile_contractor = Profile.create!(user: licensed_contractor, profile_type: :service_provider, business_name: "Charlie's Construction", full_name: "Charlie Sheen", tax_id: "987654321")

# Assign license
profile_contractor.license_types << class_c

# Assign services
profile_unlicensed.services << [plumbing, painting, construction]
profile_contractor.services << [plumbing, electrical, roofing, construction]

puts "✅ Profiles, licenses, and provider services seeded"

# ===============================
# PROPERTIES
# ===============================
property1 = Property.create!(user: homeowner1, title: "Maple Street House", city: "New York", address: "123 Maple St")
property2 = Property.create!(user: homeowner1, title: "Oak Avenue Condo", city: "Boston", address: "456 Oak Ave")
property3 = Property.create!(user: homeowner1, title: "Tallimore Estates", city: "Chantilly", address: "28 Tallimore Ave")
property4 = Property.create!(user: homeowner2, title: "Cedar Lane House", city: "Chicago", address: "101 Cedar Ln")
property5 = Property.create!(user: homeowner2, title: "Pine Street Apartment", city: "Seattle", address: "202 Pine St")
property6 = Property.create!(user: homeowner2, title: "Birchwood Villa", city: "Austin", address: "303 Birchwood Ave")
puts "✅ Properties seeded"

# ===============================
# LISTINGS
# ===============================
# Alice's listings
listing1 = Listing.create!(user: homeowner1, property: property1, property_type: "condo", title: "Fix Kitchen Sink", description: "The sink is leaking badly", listing_type: :service, status: :open, budget: 200)
listing2 = Listing.create!(user: homeowner1, property: property2, title: "Paint Living Room", description: "Need fresh paint in living room", listing_type: :service, status: :open, budget: 350)
listing3 = Listing.create!(user: homeowner1, property: property2, title: "Shed framing repair", description: "Minor framing and reinforcement work", listing_type: :build_opportunity, status: :open, budget: 850)
listing4 = Listing.create!(user: homeowner1, property: property3, title: "Bathroom Remodel", description: "Mid-level bathroom upgrade", listing_type: :build_opportunity, status: :open, budget: 2_500)
listing5 = Listing.create!(user: homeowner1, property: property3, title: "Add basement room", description: "Full basement expansion with permits", listing_type: :build_opportunity, status: :open, budget: 24_000)
listing_repair1 = Listing.create!(user: homeowner1, property: property1, title: "Fence Repair Needed", description: "Wood fence is damaged; needs replacement boards and paint", listing_type: :service, status: :open, budget: 450)
listing_pet2 = Listing.create!(user: homeowner1, property: property3, title: "Pet Sitting: Cat & Dog", description: "Need reliable pet sitter for 5 days", listing_type: :service, status: :open, budget: 200)

# Eve's listings
listing7 = Listing.create!(user: homeowner2, property: property4, title: "Fix Leaky Faucet", description: "Kitchen faucet leaking", listing_type: :service, status: :open, budget: 300)
listing8 = Listing.create!(user: homeowner2, property: property5, property_type: "condo", title: "Paint Bedroom", description: "Need bedroom painted", listing_type: :service, status: :open, budget: 450)
listing_repair2 = Listing.create!(user: homeowner2, property: property4, title: "Deck Repair & Staining", description: "Minor deck repairs plus staining for protection", listing_type: :service, status: :open, budget: 900)
listing_pet1 = Listing.create!(user: homeowner2, property: property5, property_type: "condo", title: "Dog Sitting Needed", description: "Looking for dog walker/sitter for 3 days next week", listing_type: :service, status: :open, budget: 150)
listing_flip1 = Listing.create!(user: homeowner2, property: property6, title: "Fix & Flip: Birchwood Villa", description: "Quick flip opportunity; minor renovations needed", listing_type: :investment_opportunity, status: :open, budget: 40_000, deal_type: :flip)
listing_flip2 = Listing.create!(user: homeowner2, property: property5, property_type: "multi_family", title: "Oak Street Flip", description: "Opportunity to flip mid-range apartment", listing_type: :investment_opportunity, status: :open, budget: 25_000, deal_type: :flip)
puts "✅ Listings created"

# ===============================
# LINK SERVICES TO LISTINGS
# ===============================
listing1.services << [plumbing, painting]
listing2.services << [painting, plumbing]
listing3.services << [construction, electrical]
listing4.services << [construction, flooring]
listing5.services << [construction, plumbing]
listing_repair1.services << [construction]
listing_repair2.services << [construction]
listing_pet1.services << [dog_walker]
listing_pet2.services << [dog_walker]
listing_flip1.services << [construction]
listing_flip2.services << [construction]
puts "✅ Listing services linked"


# ===============================
# LEADS
# ===============================
lead1 = Lead.create!(
  user: homeowner1,
  property: property1,
  title: "Leaky Kitchen Sink",
  description: "The kitchen sink is leaking badly. Need repair ASAP.",
  budget: 200,
  status: :initiated
)
lead1.services << [plumbing, electrical]

lead2 = Lead.create!(
  user: homeowner1,
  property: property2,
  title: "Living Room Painting",
  description: "Need living room painted before next weekend.",
  budget: 300,
  status: :initiated
)
lead2.services << [painting]

lead3 = Lead.create!(
  user: homeowner2,
  property: property4,
  title: "Deck Repair & Staining",
  description: "Minor deck repairs plus staining for protection.",
  budget: 900,
  status: :initiated
)
lead3.services << [construction]

lead4 = Lead.create!(
  user: homeowner2,
  property: property5,
  title: "Dog Walker Needed",
  description: "Looking for dog walker/sitter for 3 days next week.",
  budget: 150,
  status: :initiated
)
lead4.services << [dog_walker]

puts "✅ Leads seeded"

# ===============================
# BIDS
# ===============================
def create_bid(user, profile, listing, amount, message)
  membership = user.subscription&.membership
  return unless membership
  bid_range = membership.features["bid_range"]
  min = bid_range["low"]
  max = bid_range["high"]
  return if amount < min || amount > max

  Bid.create!(listing: listing, profile: profile, amount: amount, message: message, status: :pending)
end

# Unlicensed provider bids (low budget)
create_bid(unlicensed_provider, profile_unlicensed, listing1, 180, "Quick affordable fix")
create_bid(unlicensed_provider, profile_unlicensed, listing2, 300, "Clean professional job")
create_bid(unlicensed_provider, profile_unlicensed, listing3, 750, "Handled similar framing before")
create_bid(unlicensed_provider, profile_unlicensed, listing_repair2, 900, "Attempt high job — blocked by range")
create_bid(unlicensed_provider, profile_unlicensed, listing_pet1, 140, "Friendly pet sitter available")

# Licensed contractor bids (full range)
create_bid(licensed_contractor, profile_contractor, listing3, 900, "Licensed, insured, fast turnaround")
create_bid(licensed_contractor, profile_contractor, listing4, 2_200, "Bathroom remodel with permits")
create_bid(licensed_contractor, profile_contractor, listing5, 23_000, "Full crew, inspections included")
create_bid(licensed_contractor, profile_contractor, listing7, 280, "Quick plumbing fix")
create_bid(licensed_contractor, profile_contractor, listing8, 400, "Painting with high finish")
create_bid(licensed_contractor, profile_contractor, listing_flip1, 35_000, "Experienced flip team ready")
create_bid(licensed_contractor, profile_contractor, listing_repair1, 400, "Quick repair, quality work")
puts "✅ Bids seeded"

puts "🌱 Running faceted search test cases..."

# Map service names to IDs for filtering
services = Service.all.index_by(&:name)

# -------------------------------
# 1️⃣ Search by Service
# -------------------------------
puts "\nTest 1: Listings with Painting service"
painting_listings = Listing.joins(:services).where(services: { id: services["Painting"].id }).distinct
puts "Found #{painting_listings.count} listings with Painting service"
painting_listings.each { |l| puts "- #{l.title} ($#{l.budget}) | Services: #{l.services.map(&:name).join(', ')}" }

puts "\nTest 2: Listings with Plumbing service"
plumbing_listings = Listing.joins(:services).where(services: { id: services["Plumbing"].id }).distinct
puts "Found #{plumbing_listings.count} listings with Plumbing service"
plumbing_listings.each { |l| puts "- #{l.title} ($#{l.budget}) | Services: #{l.services.map(&:name).join(', ')}" }

puts "\nTest 3: Listings with Dog Walker / Pet Care service"
dog_walker_listings = Listing.joins(:services).where(services: { id: services["Dog Walker / Pet Care"].id }).distinct
puts "Found #{dog_walker_listings.count} listings with Dog Walker / Pet Care service"
dog_walker_listings.each { |l| puts "- #{l.title} ($#{l.budget}) | Services: #{l.services.map(&:name).join(', ')}" }

# -------------------------------
# 2️⃣ Combined facets (service + budget)
# -------------------------------
puts "\nTest 4: Painting listings under $500"
painting_under_500 = Listing.joins(:services)
                            .where(services: { id: services["Painting"].id })
                            .where("budget <= ?", 500)
                            .distinct
puts "Found #{painting_under_500.count} listings"
painting_under_500.each { |l| puts "- #{l.title} ($#{l.budget}) | Services: #{l.services.map(&:name).join(', ')}" }

# -------------------------------
# 3️⃣ Faceted search helper (text + service)
# -------------------------------
puts "\nTest 5: Listings with 'Living Room' in text AND Painting service"
faceted_painting = Listing.faceted_search(query: "Living Room")
                          .joins(:services)
                          .where(services: { id: services["Painting"].id })
                          .distinct
puts "Found #{faceted_painting.count} listings"
faceted_painting.each { |l| puts "- #{l.title} ($#{l.budget}) | Services: #{l.services.map(&:name).join(', ')}" }

# -------------------------------
# 4️⃣ Filter by listing type
# -------------------------------
puts "\nTest 6: Filter by listing_type :service"
service_listings = Listing.faceted_search(listing_type: "service")
puts "Found #{service_listings.count} service listings"
service_listings.each { |l| puts "- #{l.title}" }

puts "\nTest 7: Filter by listing_type :investment_opportunity"
investment_listings = Listing.faceted_search(listing_type: "investment_opportunity")
puts "Found #{investment_listings.count} investment listings"
investment_listings.each { |l| puts "- #{l.title}" }

# -------------------------------
# 5️⃣ Filter by budget
# -------------------------------
puts "\nTest 8: Listings between $200 and $500"
budget_listings = Listing.faceted_search(min_budget: 200, max_budget: 500)
puts "Found #{budget_listings.count} listings"
budget_listings.each { |l| puts "- #{l.title} ($#{l.budget})" }

# -------------------------------
# 6️⃣ Filter by deal type
# -------------------------------
puts "\nTest 9: Listings with deal_type :flip"
flip_listings = Listing.faceted_search(deal_type: "flip")
puts "Found #{flip_listings.count} flip listings"
flip_listings.each { |l| puts "- #{l.title} ($#{l.budget})" }

# -------------------------------
# 7️⃣ Combined facets example
# -------------------------------
puts "\nTest 10: Service listings under $500 with 'Paint' in title/description"
combined_listings = Listing.faceted_search(listing_type: "service", min_budget: 0, max_budget: 500, query: "Paint")
puts "Found #{combined_listings.count} listings"
combined_listings.each { |l| puts "- #{l.title} ($#{l.budget}) | Services: #{l.services.map(&:name).join(', ')}" }

puts "✅ Faceted search test cases complete!"

puts "🎉 SEEDING COMPLETE!"
