class Loan < ApplicationRecord
  # ── Associations ────────────────────────────────────────────────
  belongs_to :customer
  belongs_to :added_by,  class_name: "User"
  belongs_to :issued_by, class_name: "User", optional: true

  has_one_attached :proof_of_issue
  has_one_attached :qr_image

  # ── Constants ───────────────────────────────────────────────────
  STATUSES      = %w[active overdue completed completed_late].freeze
  SESSION_TYPES = %w[weekly daily].freeze

  # Sessions per month for each type.
  # "daily" = 6 days/week × ~4.33 weeks ≈ 26 sessions/month (we use 26 for clean math)
  SESSIONS_PER_MONTH = { "weekly" => 4, "daily" => 26 }.freeze

  # Interest rate per month (default 8 %)
  DEFAULT_MONTHLY_RATE = 0.08

  # Days per month used for maturity date calculation
  DAYS_PER_MONTH = 29

  # ── Validations ─────────────────────────────────────────────────
  validates :loan_amount,        presence: true, numericality: { greater_than: 0 }
  validates :total_months_to_pay, presence: true, numericality: { greater_than: 0 }
  validates :session_type,       inclusion: { in: SESSION_TYPES }
  validates :status,             inclusion: { in: STATUSES }
  validates :interest_rate,      presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :proof_of_issue_is_image
  validate :qr_image_is_image

  # ── Callbacks ───────────────────────────────────────────────────
  before_validation :compute_derived_fields
  before_save       :sync_status_from_dates

  # ── Scopes ──────────────────────────────────────────────────────
  scope :active,         -> { where(status: "active") }
  scope :overdue,        -> { where(status: "overdue") }
  scope :completed,      -> { where(status: %w[completed completed_late]) }

  # ── Instance helpers ────────────────────────────────────────────

  # Call this any time you want to recheck whether the loan is overdue.
  def refresh_status!
    sync_status_from_dates
    save! if status_changed?
  end

  def overdue?
    maturity_date.present? && Date.today > maturity_date && %w[active overdue].include?(status)
  end

  def display_status
    {
      "active"         => "Active",
      "overdue"        => "Overdue",
      "completed"      => "Completed",
      "completed_late" => "Completed (L)"
    }[status] || status.humanize
  end

  def status_color
    {
      "active"         => "blue",
      "overdue"        => "red",
      "completed"      => "green",
      "completed_late" => "yellow"
    }[status] || "gray"
  end

  private

  # ── Derived field computation ────────────────────────────────────
  def compute_derived_fields
    return unless loan_amount.present? && total_months_to_pay.present? && session_type.present?

    # Interest rate: default 8 % per month, compounded over total months
    self.interest_rate ||= DEFAULT_MONTHLY_RATE * total_months_to_pay

    # Total sessions
    sessions_per_month      = SESSIONS_PER_MONTH[session_type] || 4
    self.total_sessions     = sessions_per_month * total_months_to_pay

    # Total balance = principal + interest
    self.total_balance      = loan_amount * (1 + interest_rate)

    # Pay per session (rounded up to nearest centavo)
    self.pay_per_session    = (total_balance / total_sessions).ceil(2) if total_sessions&.positive?

    # Remaining balance defaults to total balance on creation
    self.remaining_balance  = total_balance if remaining_balance.nil? || remaining_balance.zero?

    # Maturity date: DAYS_PER_MONTH × total_months_to_pay after date_issued (or today as fallback)
    base_date = date_issued || Date.today
    self.maturity_date      = base_date + (DAYS_PER_MONTH * total_months_to_pay).days
  end

  def sync_status_from_dates
    # Don't override a completed status
    return if %w[completed completed_late].include?(status)

    self.status = overdue? ? "overdue" : "active"
  end

  def proof_of_issue_is_image
    return unless proof_of_issue.attached?
    unless proof_of_issue.content_type.start_with?("image/")
      errors.add(:proof_of_issue, "must be an image file")
    end
  end

  def qr_image_is_image
    return unless qr_image.attached?
    unless qr_image.content_type.start_with?("image/")
      errors.add(:qr_image, "must be an image file")
    end
  end
end