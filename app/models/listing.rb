class Listing < ApplicationRecord
  attr_accessor :property_title, :property_address

  belongs_to :user
  belongs_to :property, optional: true

  has_many :listing_services, dependent: :destroy
  has_many :services, through: :listing_services
  has_many :bids, dependent: :destroy   # ✅ THIS WAS MISSING
  has_one :awarded_bid, -> { where(status: [:accepted, :paid, :complete]) }, class_name: "Bid"

  before_save :update_search_vector

  PROPERTY_TYPES = %w[
  single_family
  condo
  townhouse
  multi_family
  duplex
  triplex
  quadplex
  manufactured
  land
  commercial
  mixed_use
].freeze



  enum listing_type: {
    service: 0,
    property_sale: 1,
    build_opportunity: 2,
    investment_opportunity: 3
  }

  enum status: {
    open: 0,
    awarded: 1,
    in_progress: 2,
    complete: 3,
    cancelled: 4,
    expired: 5
  }

  enum deal_type: {
    flip: 0,
    buy_hold: 1,
    wholesale: 2
  }

  validates :title, :description, :budget, presence: true
  validates :budget, numericality: { greater_than: 0 }
  validates :property_type,
            inclusion: { in: PROPERTY_TYPES }
  # validate :listing_must_be_open

  scope :open, -> { where(status: "open") }
  scope :complete, -> { where(status: "complete") }

  scope :text_search, ->(query) {
    return all if query.blank?

    where(
      "search_vector @@ plainto_tsquery('english', ?)",
      query
    )
  }

  scope :by_type, ->(type) {
    where(listing_type: type) if type.present?
  }

  scope :by_status, ->(status) {
    where(status: status) if status.present?
  }

  scope :min_budget, ->(amount) {
    where("budget >= ?", amount) if amount.present?
  }

  scope :max_budget, ->(amount) {
    where("budget <= ?", amount) if amount.present?
  }

  scope :by_deal_type, ->(deal_type) {
    where(deal_type: deal_type) if deal_type.present?
  }

  scope :by_condition, ->(condition) {
    where(property_condition: condition) if condition.present?
  }

  scope :by_services, ->(service_ids) {
    if service_ids.present?
      joins(:services).where(services: { id: service_ids }).distinct
    end
  }

  scope :by_property_type, ->(type) {
    where(property_type: type) if type.present?
  }

  scope :single_family, -> { where(property_type: "single_family") }

  def self.faceted_search(params)
    results = self

    # keyword search
    results = results.text_search(params[:q]) if params[:q].present?

    # services
    if params[:service_ids].present?
      results = results.joins(:services)
                       .where(services: { id: params[:service_ids] })
    end

    # standard facets
    results = results.by_type(params[:listing_type])
    results = results.by_status(params[:status])
    results = results.min_budget(params[:min_budget])
    results = results.max_budget(params[:max_budget])
    results = results.by_deal_type(params[:deal_type])
    results = results.by_condition(params[:property_condition])
    results = results.by_property_type(params[:property_type])

    results.distinct
  end

  def self.facet_counts(base_relation, base_scope)
    counts = {
      listing_type:       base_relation.group(:listing_type).count,
      status:             base_relation.group(:status).count,
      deal_type:          base_relation.group(:deal_type).count,
      property_condition: base_relation.group(:property_condition).count
    }

    # Property type counts should ignore faceted_search filters
    counts[:property_type] = PROPERTY_TYPES.each_with_object({}) do |ptype, hash|
      hash[ptype] = base_scope.where(property_type: ptype).count
    end

    counts
  end

  def update_lowest_bid!
    min_bid = bids.where(status: [:pending, :shortlisted, :accepted]).minimum(:amount)
    update(lowest_bid: min_bid)
  end

  # Return the bid that was awarded, even if completed
  def winning_bid
    bids.where(status: :accepted)
        .order(updated_at: :desc)
        .first
  end

  def award_bid!(bid)
    transaction do
      bids.where(status: [:accepted]).update_all(status: :rejected) # reject previous accepted bids
      bid.update!(status: :accepted)
      update!(status: :awarded)
    end
  end

  def editable?
    open?
  end

  def listing_must_be_open
    errors.add(:listing, "is closed") unless listing.open?
  end

  def can_bid_on?(user)
    return false unless open?

    profile = user.service_provider_profile

    # Handyman / unlicensed
    if profile.nil? || !profile.licensed?
      return budget.to_f <= 1_000
    end

    # Licensed provider
    if budget.to_f <= profile.max_project_budget
      true
    else
      # Above class limit, only verified providers
      profile.verified_provider?
    end
  end

  def nearby_listings
    provider = current_user.service_provider_profile

    radius = current_user.subscription&.membership&.service_radius || 25

    listings = Listing.joins(:property)
                      .merge(Property.near([provider.latitude, provider.longitude], radius))

    render json: listings
  end

  def update_search_vector
    sql = self.class.sanitize_sql_array([
                                          "to_tsvector('english', ?)",
                                          search_text
                                        ])

    self.search_vector =
      self.class.connection.select_value("SELECT #{sql}")
  end

  def search_text
    [title, description].compact.join(" ")
  end

  def single_family?
    property_type == "single_family"
  end
end
