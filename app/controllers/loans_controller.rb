class LoansController < ApplicationController
  before_action :require_login
  before_action :set_customer, only: %i[index new create]
  before_action :set_loan, only: %i[show edit update]
  before_action :set_customer_from_loan, only: %i[show edit update]

  def index
    @loans = @customer.loans.includes(:issued_by, :added_by).order(created_at: :desc)
  end

  def show; end

  def new
    @loan = @customer.loans.build(
      total_months_to_pay: 2,
      session_type: "weekly",
      interest_rate: 0.16
    )
  end

  def create
    @loan = @customer.loans.build(loan_params)
    @loan.added_by = current_user

    if @loan.save
      redirect_to loan_path(@loan), notice: "Loan created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @loan.update(loan_params)
      @loan.refresh_status!
      redirect_to loan_path(@loan), notice: "Loan updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:customer_id])
  end

  def set_loan
    @loan = Loan.find(params[:id])
  end

  def set_customer_from_loan
    @customer = @loan.customer
  end

  def loan_params
    params.require(:loan).permit(
      :date_issued,
      :issued_by_id,
      :loan_amount,
      :total_months_to_pay,
      :session_type,
      :interest_rate,
      :remaining_balance,
      :status,
      :proof_of_issue,
      :qr_image
    )
  end
end