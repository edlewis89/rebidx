class Lead < ApplicationRecord
  belongs_to :user
  belongs_to :property, optional: true
  belongs_to :claimed_by, class_name: "User", optional: true

  has_many :lead_services, dependent: :destroy
  has_many :services, through: :lead_services

  enum status: {
    initiated: 0,    # slightly more formal
    contacted: 1,
    in_progress: 2,
    converted: 3,
    closed: 4
  }

  validates :title, :description, presence: true

  # Unclaimed leads
  scope :unclaimed, -> { where(claimed_by_id: nil) }

  # Convert lead to Listing
  def convert_to_listing!
    transaction do
      listing = Listing.create!(
        user: user,
        property: property,
        title: title,
        description: description,
        budget: budget || 0,
        listing_type: :service,
        status: :open
      )
      listing.services << services
      update!(status: :converted)
      listing
    end
  end
end
