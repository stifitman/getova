class CreateRepresentations < ActiveRecord::Migration
  def change
    create_table :representations do |t|
      t.integer :individual_id
      t.text :content
      t.integer :format_id

      t.timestamps
    end
  end
end
