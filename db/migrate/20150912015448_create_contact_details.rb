class CreateContactDetails < ActiveRecord::Migration
  def change
    create_table :contact_details do |t|
      t.string :type
      t.string :subtype
      t.string :detail
      t.references :contact, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
