class CreateIndividualFormats < ActiveRecord::Migration
  def change
    create_table :individual_formats do |t|
      t.string :name
      t.text :baseToFormat
      t.text :formatToBase

      t.timestamps
    end
  end
end
