class Advertisement < ApplicationRecord
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [250, 150], processor: :mini_magick
  end
  validates :title, :placement, presence: true
  enum placement: { dashboard_sidebar: 0, navbar: 1, homepage: 2, flash_message: 3 } # integer-backed

  scope :active, -> {
    where(active: true)
      .where("(start_date IS NULL OR start_date <= ?) AND (end_date IS NULL OR end_date >= ?)", Date.today, Date.today)
  }
  scope :by_placement, ->(placement) { where(placement: placements[placement]) if placements.key?(placement.to_s) }
end
