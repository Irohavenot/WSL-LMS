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
def payments
    # Month filter (YYYY-MM). Default current month.
    @month = params[:month].presence || Date.today.strftime("%Y-%m")
    month_date = Date.strptime("#{@month}-01", "%Y-%m-%d")
    @month_start = month_date.beginning_of_month
    @month_end   = month_date.end_of_month

    # Mode filter: weekly or daily
    @mode = params[:mode].presence_in(%w[weekly daily]) || "weekly"

    # For daily mode: show only one week (Mon-Sat) at a time
    if @mode == "daily"
      # week_start is a date string. Default first Monday in month range (or month_start if already Monday)
      ws = params[:week_start].present? ? Date.parse(params[:week_start]) : @month_start
      @week_start = ws.beginning_of_week(:monday)
      @week_end   = @week_start + 5.days # Mon-Sat
      @dates = (@week_start..@week_end).to_a
    else
      # Weekly: show Sundays within the month
      first_sun = @month_start.beginning_of_week(:sunday)
      @dates = (first_sun..@month_end).select { |d| d.sunday? && d.month == @month_start.month }
    end

    # Loans to show: active/overdue loans (adjust if you want completed too)
    @loans = Loan.includes(:customer, :payments)
                .where(status: %w[active overdue])
                .order("customers.last_name ASC", "customers.first_name ASC")
                .references(:customers)
end

  def records
  end

  def reports
  end
end