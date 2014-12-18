class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :type
      t.integer :api_id, :null => :false
      t.string :encrypted_data

      t.timestamps
    end
  end
end
