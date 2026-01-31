class Property < ApplicationRecord
  belongs_to :user
  has_many :listings, dependent: :destroy

  validates :title, :address, presence: true
end
