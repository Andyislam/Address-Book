class AddUserToContacts < ActiveRecord::Migration
  def change
  	add_column :contacts, :name, :string
  	add_column :contacts, :phone_array, :string
  	add_column :contacts, :email_array, :string
  	add_column :contacts, :google_synced, :boolean,:default => false
    add_reference :contacts, :user, index: true, foreign_key: true
  end
end
