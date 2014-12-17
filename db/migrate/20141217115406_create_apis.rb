class CreateApis < ActiveRecord::Migration
  def change
    create_table :apis do |t|
      t.string :type
      t.string :name
      t.string :encrypted_data

      t.timestamps
    end

    Insightly.create
  end
end
