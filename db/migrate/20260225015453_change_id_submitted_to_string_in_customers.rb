class ChangeIdSubmittedToStringInCustomers < ActiveRecord::Migration[8.1]
  def change
    change_column :customers, :id_submitted, :string
  end
end