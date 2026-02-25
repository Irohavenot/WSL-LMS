class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :last_name
      t.string :first_name
      t.string :middle_initial
      t.date :date_of_birth
      t.text :address
      t.string :contact_number
      t.string :id_submitted
      t.string :co_maker
      t.string :collateral
      t.integer :total_no_of_loans
      t.references :added_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
