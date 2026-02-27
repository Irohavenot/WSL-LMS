class PaymentsController < ApplicationController
  before_action :set_loan, only: %i[index new create]

  def index
    scope = @loan.payments

    # Month filter — filters by the SESSION date (paid_at)
    if params[:month].present?
      from = Date.strptime("#{params[:month]}-01", "%Y-%m-%d")
      to   = from.end_of_month
      scope = scope.where(paid_at: from.beginning_of_day..to.end_of_day)
    end

    # Optional: search by collector
    if params[:q].present?
      scope = scope.where("collector ILIKE ?", "%#{params[:q]}%")
    end

    # Sort
    sort  = params[:sort].presence_in(%w[newest oldest]) || "newest"
    scope = (sort == "oldest") ? scope.order(paid_at: :asc) : scope.order(paid_at: :desc)

    @payments = scope

    # Totals for the filtered set
    @total_paid    = @payments.sum(:amount_paid)
    @total_penalty = @payments.sum(:penalty)
  end

  def new
    @payment = @loan.payments.new(
      collector:   current_user&.full_name,
      paid_at:     Time.current,    # session date defaults to now
      received_at: Time.current     # received date defaults to now
    )
  end

  def create
    @payment = @loan.payments.new(payment_params)

    # If received_at wasn't explicitly submitted, default to now
    @payment.received_at ||= Time.current

    if @payment.save
      redirect_to loan_payments_path(@loan), notice: "Payment recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_loan
    @loan = Loan.find(params[:loan_id])
  end

  def payment_params
    params.require(:payment).permit(
      :amount_paid,
      :penalty,
      :paid_at,        # session date (which collection day this covers)
      :received_at,    # physical receipt date (accountability/audit)
      :collector
    )
  end
end