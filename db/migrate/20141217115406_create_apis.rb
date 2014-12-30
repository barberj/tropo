class CreateApis < ActiveRecord::Migration
  def change
    create_table :apis do |t|
      t.string :type, null: false
      t.string :token, null: false
      t.string :encrypted_client_data

      t.timestamps null: false
    end

    create_table :api_configs do |t|
      t.string :encrypted_config_data

      t.integer :api_id, null: false

      t.timestamps null: false
    end
  end
end
