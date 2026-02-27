class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :loan, null: false, foreign_key: true
      t.decimal :amount_paid, precision: 12, scale: 2, null: false, default: 0
      t.decimal :penalty,     precision: 12, scale: 2, null: false, default: 0
      t.datetime :paid_at, null: false
      t.string :collector, null: false
      t.timestamps
    end
  end
end
