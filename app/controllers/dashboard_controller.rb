class DashboardController < ApplicationController
  before_action :require_login

  def index
  end

  def customers
    @customers = Customer.order(created_at: :desc)
  end

  def loans
  end

  def records
  end

  def reports
  end
end