class DashboardController < ApplicationController
  before_action :require_login

  def index
  end

  def customers
    @customers = Customer.order(created_at: :desc)
  end

# app/controllers/dashboard_controller.rb
def loans
  @loans = Loan.includes(:customer, :issued_by, :added_by).order(created_at: :desc)
end

  def records
  end

  def reports
  end
end