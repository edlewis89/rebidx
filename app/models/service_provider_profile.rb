class ServiceProviderProfile < ApplicationRecord
  belongs_to :user

  has_many :provider_services, dependent: :destroy
  has_many :services, through: :provider_services
  has_many :service_provider_licenses, dependent: :destroy
  has_many :license_types, through: :service_provider_licenses
  has_many :ratings

  has_one_attached :license do |attachable|
    attachable.variant :thumb, resize_to_limit: [250, 150], processor: :mini_magick
  end
  has_one_attached :government_id do |attachable|
    attachable.variant :thumb, resize_to_limit: [250, 150], processor: :mini_magick
  end
  has_one_attached :business_license_file do |attachable|
    attachable.variant :thumb, resize_to_limit: [250, 150], processor: :mini_magick
  end
  has_one_attached :tax_document do |attachable|
    attachable.variant :thumb, resize_to_limit: [250, 150], processor: :mini_magick
  end

  validates :business_name, :full_name, presence: true
  validates :tax_id, presence: true, if: -> { license_types.any?(&:requires_verification?) }

  # Delegate status methods
  delegate :unverified?, :pending?, :verified?, :rejected?, :not_required?, to: :verification_profile, allow_nil: true

  after_commit :create_license_check, if: :license_uploaded?
  after_commit :create_identity_check, if: -> { government_id.attached? }
  after_save :trigger_verification_if_required

  after_update :sync_verification_profile, if: :saved_change_to_verified?
  geocoded_by :full_address
  after_validation :geocode, if: :will_save_change_to_address? ||
    :will_save_change_to_city? ||
    :will_save_change_to_state? ||
    :will_save_change_to_zipcode?




  # ---- Verification Access (READ ONLY) ----

  def verification_profile
    user.ensure_verification_profile!
  end

  def verified_provider?
    verification_profile.verified?
  end

  def pending_verification?
    verification_profile.pending?
  end

  def rejected_verification?
    verification_profile.rejected?
  end

  def needs_verification?
    requires_verification? && !verified_provider?
  end

  # ---- License Logic ----

  def license_uploaded?
    license.attached?
  end

  def license_valid?
    return false unless license_uploaded?
    return true unless license_expires_at.present?
    license_expires_at > Time.current
  end

  def requires_verification?
    license_types.where(requires_verification: true).any?
  end

  def average_rating
    ratings.average(:score)&.round(2) || 0
  end

  def handyman?
    !license_uploaded?
  end

  # ---- Verification Check Creation ----

  def create_license_check
    check = verification_profile.verification_checks.find_or_initialize_by(kind: "business_license")

    check.update!(
      status: "pending",
      provider: "internal",
      data: {
        expires_at: license_expires_at,
        license_type_ids: license_types.pluck(:id)
      }
    )
  end

  def create_identity_check
    verification_profile.verification_checks.find_or_create_by!(kind: "identity") do |check|
      check.status = "pending"
      check.provider = "manual_review"
    end
  end

  def trigger_verification_if_required
    return unless requires_verification?
    return if verification_profile.pending? || verification_profile.verified?

    verification_profile.update!(status: "pending")
  end

  def max_project_budget
    return 1_000 unless license_uploaded?

    case license_class
    when "C"
      10_000
    when "B"
      120_000
    when "A"
      Float::INFINITY
    else
      1_000
    end
  end

  def licensed?
    license_uploaded?
  end

  # Updates the associated verification_profile when verified changes
  def sync_verification_profile
    return unless self[:verified] # use column, not delegated verified?

    vp = verification_profile
    vp.update!(
      status: "verified",
      verified_at: Time.current
    )
    vp.verification_checks.update_all(status: "approved")
  end

  def full_address
    [address, city, state, zipcode].compact.join(", ")
  end
end

# class ServiceProviderProfile < ApplicationRecord
#
#
#   belongs_to :user
#   delegate :verification_profile, to: :user
#
#   has_many :provider_services, dependent: :destroy
#   has_many :services, through: :provider_services
#
#   # Attachments for verification
#   has_one_attached :license
#   has_one_attached :government_id
#   has_one_attached :business_license_file
#   has_one_attached :tax_document
#
#   #has_many :service_provider_profile_class_licenses
#   #has_many :class_licenses, through: :service_provider_profile_class_licenses
#
#   has_many :service_provider_licenses, dependent: :destroy
#   has_many :license_types, through: :service_provider_licenses
#   has_many :ratings
#
#   validates :business_name, presence: true
#
#   # enum verification_status: {
#   #   unverified: "unverified",
#   #   pending: "pending",
#   #   verified: "verified",
#   #   rejected: "rejected",
#   #   not_required: "not_required"
#   # }
#
#   validates :business_name, :full_name, presence: true
#   #validates :tax_id, presence: true, if: -> { verification_status != "pending" }
#   validates :tax_id, presence: true, if: -> { license_types.any?(&:requires_verification?) }
#
#   # Sync Provider Verification Status to VerificationProfile
#   # after_save :sync_verification_status
#   after_commit :create_license_check, if: :license_uploaded?
#   after_commit :create_identity_check, if: -> { government_id.attached? }
#   after_save :trigger_verification_if_required
#
#   # def sync_verification_status
#   #   return unless verification_profile
#   #
#   #   if verified?
#   #     verification_profile.update!(status: "verified")
#   #   elsif pending_verification?
#   #     verification_profile.update!(status: "pending")
#   #   elsif rejected_verification?
#   #     verification_profile.update!(status: "rejected")
#   #   else
#   #     verification_profile.update!(status: "unverified")
#   #   end
#   # end
#
#   def create_license_check
#     return unless verification_profile
#
#     check = verification_profile.verification_checks.find_or_initialize_by(kind: "business_license")
#
#     check.update!(
#       status: "pending",
#       provider: "internal",
#       data: {
#         expires_at: license_expires_at,
#         license_type_ids: license_types.pluck(:id)
#       }
#     )
#   end
#
#   def create_identity_check
#     return unless verification_profile
#
#     verification_profile.verification_checks.find_or_create_by!(
#       kind: "identity"
#     ) do |check|
#       check.status = "pending"
#       check.provider = "manual_review"
#     end
#   end
#
#   def trigger_verification_if_required
#     return unless requires_verification?
#     return if verification_profile.pending? || verification_profile.verified?
#
#     verification_profile.update!(status: "pending")
#   end
#
#
#   # Returns true if a license file has been uploaded
#   def license_uploaded?
#     license.attached?
#   end
#
#   # Optional convenience: verification status helpers
#   def verified_provider?
#     verification_profile&.verified?
#   end
#
#   def pending_verification?
#     verification_profile&.pending?
#   end
#
#   def rejected_verification?
#     verification_profile&.rejected?
#   end
#
#   def needs_verification?
#     requires_verification? && !verified_provider?
#   end
#
#   def verification_required?
#     needs_verification?
#   end
#
#   def verified?
#     verification_profile&.verified?
#   end
#
#   def requires_verification?
#     license_types.where(requires_verification: true).any?
#   end
#
#   def average_rating
#     ratings.average(:score)&.round(2) || 0
#   end
#
#   def license_valid?
#     return false unless license_uploaded?
#     return true unless license_expires_at.present?
#     license_expires_at > Time.current
#   end
#
#   def needs_verification?
#     requires_verification? && !verification_profile&.verified?
#   end
#
#   def verification_profile
#     user.verification_profile || user.create_verification_profile(status: "unverified")
#   end
# end
