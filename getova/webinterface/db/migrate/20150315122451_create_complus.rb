class CreateComplus < ActiveRecord::Migration
  def change
    create_table :complus do |t|
      t.string :data

      t.timestamps
    end
  end
end
