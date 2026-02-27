class Payment < ApplicationRecord
  belongs_to :loan

  before_validation :set_paid_at, on: :create
  before_validation :set_default_penalty, on: :create

  validates :amount_paid, numericality: { greater_than_or_equal_to: 0 }
  validates :penalty, numericality: { greater_than_or_equal_to: 0 }
  validates :collector, presence: true
  validates :paid_at, presence: true

  after_create :apply_to_loan!

  private

  def set_paid_at
    self.paid_at ||= Time.current
  end

  # Default penalty rule:
  # penalty = max(pay_per_session - amount_paid, 0)
  # Collector can override by explicitly passing penalty.
  def set_default_penalty
    return if penalty.present? # collector explicitly set it

    expected = loan.pay_per_session.to_d
    paid     = amount_paid.to_d
    self.penalty = [expected - paid, 0.to_d].max
  end

  # Apply rules to remaining_balance:
  # remaining_balance = remaining_balance - amount_paid + penalty
  def apply_to_loan!
    loan.with_lock do
      new_balance = loan.remaining_balance.to_d - amount_paid.to_d + penalty.to_d
      loan.remaining_balance = [new_balance, 0.to_d].max
      loan.save!
    end
  end
end