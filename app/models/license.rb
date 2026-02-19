class License < ApplicationRecord
  belongs_to :profile
  belongs_to :license_type
end
