class CreateLoans < ActiveRecord::Migration[8.1]
  def change
    create_table :loans do |t|
      t.references :customer,   null: false, foreign_key: true
      t.references :added_by,   null: false, foreign_key: { to_table: :users }
      t.references :issued_by,  null: true,  foreign_key: { to_table: :users }

      # Dates
      t.datetime :date_added,   null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.date     :date_issued

      # Core loan numbers
      t.decimal  :loan_amount,        precision: 12, scale: 2, null: false
      t.integer  :total_months_to_pay, null: false, default: 2
      t.string   :session_type,        null: false, default: "weekly"  # "weekly" | "daily"
      t.integer  :total_sessions
      t.decimal  :interest_rate,       precision: 5,  scale: 4, null: false  # stored as decimal e.g. 0.16
      t.decimal  :pay_per_session,     precision: 12, scale: 2
      t.decimal  :total_balance,       precision: 12, scale: 2
      t.decimal  :remaining_balance,   precision: 12, scale: 2
      t.date     :maturity_date

      # Status
      t.string   :status, null: false, default: "active"
      # active | overdue | completed | completed_late

      t.timestamps
    end

    add_index :loans, :status
    add_index :loans, :maturity_date
  end
end