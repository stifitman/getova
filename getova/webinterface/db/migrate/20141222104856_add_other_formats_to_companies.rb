class AddOtherFormatsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :xml, :text
    add_column :companies, :usdl, :text
    add_column :companies, :json, :text
    add_column :companies, :jsonld, :text
  end
end
