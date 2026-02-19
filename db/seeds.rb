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
unless Rails.env.production?
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
end

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
# Seed Memberships
[
  {
    name: "Free",
    price_cents: 0,
    service_radius: 10,
    features: {
      max_listings: 5,
      max_bids_per_month: 5,
      messaging: false,
      can_bid_high_value: false,
      show_ads: true,
      featured_listings: false,
      bid_range: { low: 0, high: 1000 }
    },
    active: true
  },
  {
    name: "Pro",
    price_cents: 2900,
    service_radius: 25,
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
    name: "Elite",
    price_cents: 6900,
    service_radius: 50,
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
    name: "Platinum",
    price_cents: 9900,
    service_radius: 100,
    features: {
      max_listings: 9999,
      max_bids_per_month: 9999,
      messaging: true,
      featured_listings: true,
      can_bid_high_value: true,
      priority_support: true,
      bid_range: { low: 0, high: 1_000_000 }
    },
    active: true
  }
].each do |attrs|
  Membership.find_or_create_by!(name: attrs[:name]) do |m|
    m.price_cents = attrs[:price_cents]
    m.service_radius = attrs[:service_radius]
    m.features = attrs[:features]
    m.active = attrs[:active]
  end
end

puts "✅ Memberships seeded"

# ===============================
# LICENSE TYPES
# ===============================
[
  { name: "Class A", description: "High-rise & large commercial. Full verification required.", requires_verification: true },
  { name: "Class B", description: "Mid-size residential & commercial.", requires_verification: true },
  { name: "Class C", description: "Small residential & light construction.", requires_verification: true }
].each do |attrs|
  LicenseType.find_or_create_by!(name: attrs[:name]) do |lt|
    lt.description = attrs[:description]
    lt.requires_verification = attrs[:requires_verification]
  end
end

puts "✅ License types seeded"

# ===============================
# USERS
# ===============================
# homeowner = User.create!(name: "Alice Homeowner", email: "alice@example.com", password: "password", role: :homeowner)
# unlicensed_provider = User.create!(name: "Bob Repairs", email: "bob@example.com", password: "password", role: :service_provider)
# licensed_contractor = User.create!(name: "Charlie Contractor", email: "pro@example.com", password: "password", role: :service_provider)
# admin = User.find_or_create_by(name: "Admin User", email: "admin@example.com", password: "password", role: :rebidx_admin)
User.skip_callback(:create, :after, :send_confirmation_instructions)

User.find_or_initialize_by(email: "ed@sixhattechnologies.com").tap do |user|
  user.name = "Ed Lewis (Admin)"
  user.password = "sixhattech"
  user.password_confirmation = "sixhattech"
  user.role = :rebidx_admin
  user.save!
end

User.set_callback(:create, :after, :send_confirmation_instructions)

puts "✅ Users seeded"

# ===============================
# SUBSCRIPTIONS
# ===============================
# pro_membership = Membership.find_by(name: "Pro")
# licensed_contractor.create_subscription!(membership: pro_membership, status: "active")

# puts "✅ Subscriptions seeded"

# ===============================
# SERVICES
# ===============================
# Seed Services
[
  "Plumbing",
  "Electrical",
  "Painting",
  "Roofing",
  "Construction",
  "Cleaning Service",
  "Custom / Other Service",
  "HVAC / Heating & Cooling",
  "Landscaping / Lawn Care",
  "Carpentry / Woodwork",
  "Flooring",
  "Window & Door Installation",
  "Pest Control",
  "Appliance Repair",
  "Security Systems / Smart Home",
  "Masonry / Concrete",
  "Pool & Spa Services",
  "Moving / Hauling Services",
  "Gutter & Exterior Maintenance",
  "Handyman / General Repairs",
  "Dog Walker / Pet Care"
].each do |service_name|
  Service.find_or_create_by!(name: service_name)
end

puts "✅ Services seeded"




