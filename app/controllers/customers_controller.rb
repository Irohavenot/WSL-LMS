class CustomersController < ApplicationController
  before_action :require_login
  before_action :set_customer, only: %i[show edit update]

  def index
    @customers = Customer.order(created_at: :desc)
  end

  def show; end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)
    @customer.added_by = current_user

    if @customer.save
      redirect_to @customer, notice: "Customer added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "Customer updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(
      :last_name, :first_name, :middle_initial,
      :date_of_birth, :address, :contact_number,
      :total_no_of_loans, :co_maker, :collateral,
      :id_submitted,
      :id_image,
      :remove_id_image
    )
  end
end