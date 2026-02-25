class Customer < ApplicationRecord
    VALID_PH_IDS = [
    "Philippine Passport",
    "Driver's License",
    "UMID",
    "SSS ID",
    "GSIS ID",
    "PRC ID",
    "Postal ID",
    "Voter's ID",
    "PhilHealth ID",
    "TIN ID",
    "Senior Citizen ID",
    "PWD ID",
    "National ID (PhilSys)",
    "Company ID",
    "Student ID"
  ]

  belongs_to :added_by, class_name: "User"
  has_many :loans, dependent: :destroy

  has_one_attached :id_image

  attr_accessor :remove_id_image
  before_save :purge_id_image_if_requested

  # existing validations
  validates :last_name, :first_name, :date_of_birth, :address,
            :contact_number, :id_submitted, presence: true

  validates :middle_initial, length: { maximum: 1 }, allow_blank: true

  validates :total_no_of_loans,
            numericality: { greater_than_or_equal_to: 0, only_integer: true },
            allow_nil: true

  validates :contact_number,
            format: { with: /\A[\d+\-\s()]+\z/ },
            allow_blank: true

  # ✅ ADD THIS CUSTOM VALIDATION
  validate :id_image_validation

  def full_name
    [first_name, middle_initial.presence, last_name].compact.join(" ")
  end

  private

  def purge_id_image_if_requested
    id_image.purge if remove_id_image == "1"
  end

  # ✅ ADD THIS METHOD AT THE BOTTOM
  def id_image_validation
    return unless id_image.attached?

    if id_image.byte_size > 5.megabytes
      errors.add(:id_image, "must be less than 5 MB")
    end

    acceptable_types = ["image/jpeg", "image/png", "image/webp"]
    unless acceptable_types.include?(id_image.content_type)
      errors.add(:id_image, "must be a JPG, PNG, or WEBP")
    end
  end
end