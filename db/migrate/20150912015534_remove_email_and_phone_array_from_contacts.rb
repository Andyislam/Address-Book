class RemoveEmailAndPhoneArrayFromContacts < ActiveRecord::Migration
  def change
  	remove_column :contacts, :phone_array
  	remove_column :contacts, :email_array
  	
  end
end
