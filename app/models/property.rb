class Property < ApplicationRecord
  belongs_to :user
  has_many :listings, dependent: :destroy

  geocoded_by :zipcode

  validates :title, :address, presence: true
  after_validation :geocode, if: :will_save_change_to_zipcode?
end
