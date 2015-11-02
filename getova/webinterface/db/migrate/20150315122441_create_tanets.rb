class CreateTanets < ActiveRecord::Migration
  def change
    create_table :tanets do |t|
      t.string :data

      t.timestamps
    end
  end
end
