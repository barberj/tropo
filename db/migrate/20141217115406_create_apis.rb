class CreateApis < ActiveRecord::Migration
  def change
    create_table :apis do |t|
      t.string :type
      t.string :token
      t.string :encrypted_client_data

      t.timestamps
    end

    create_table :api_configs do |t|
      t.string :api_type
      t.string :encrypted_config_data

      t.timestamps
    end

    Insightly.create
  end
end
