class CreateTanetLinkedins < ActiveRecord::Migration
  def change
    create_table :tanet_linkedins do |t|
      t.string :name
      t.string :data

      t.timestamps
    end
  end
end
