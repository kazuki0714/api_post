class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :dest
      t.string :subject
      t.string :body
      t.string :attachments

      t.timestamps
    end
  end
end
