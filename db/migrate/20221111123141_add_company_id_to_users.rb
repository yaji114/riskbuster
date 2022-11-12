class AddCompanyIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :company_id, :string, null:false
    add_index :users, :company_id, unique: true
  end
end
