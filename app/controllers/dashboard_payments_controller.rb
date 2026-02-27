class DashboardPaymentsController < ApplicationController
  def record
    loan = Loan.find(params[:loan_id])

    # Security: require password confirmation
    password = params[:password].to_s
    unless current_user&.authenticate(password)
      redirect_back fallback_location: dashboard_payments_path,
                    alert: "Invalid password. Payment not saved."
      return
    end

    paid_at    = Time.zone.parse(params[:paid_at].to_s)
    received_at = params[:received_at].present? ? Time.zone.parse(params[:received_at].to_s) : Time.current
    amount     = BigDecimal(params[:amount_paid].to_s)

    if amount < 0
      redirect_back fallback_location: dashboard_payments_path,
                    alert: "Amount must be zero or greater."
      return
    end

    penalty = params[:penalty].present? ? BigDecimal(params[:penalty].to_s) : nil

    # Session window: same calendar day
    from = paid_at.beginning_of_day
    to   = paid_at.end_of_day

    # ONE PAYMENT PER SESSION RULE:
    # Find any existing payment for this loan on the same day.
    # We either UPDATE that record or CREATE a new one — never create a second.
    payment = loan.payments.where(paid_at: from..to).order(:paid_at).first

    if payment
      # Overwrite existing payment (admin confirmed on the client side)
      payment.assign_attributes(
        amount_paid:  amount,
        collector:    current_user.full_name,
        paid_at:      paid_at,
        received_at:  received_at
      )
      payment.penalty = penalty if penalty
    else
      # No payment yet this session — create one
      payment = loan.payments.new(
        paid_at:      paid_at,
        received_at:  received_at,
        amount_paid:  amount,
        collector:    current_user.full_name
      )
      payment.penalty = penalty if penalty
    end

    if payment.save
      redirect_back fallback_location: dashboard_payments_path,
                    notice: "Payment saved (#{payment.paid_at.strftime('%b %d')} • ₱#{payment.amount_paid})."
    else
      redirect_back fallback_location: dashboard_payments_path,
                    alert: payment.errors.full_messages.to_sentence
    end
  end
end