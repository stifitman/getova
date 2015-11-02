class CreateTenders < ActiveRecord::Migration
  def change
    create_table :tenders do |t|
      t.string :data

      t.timestamps
    end
  end
end
