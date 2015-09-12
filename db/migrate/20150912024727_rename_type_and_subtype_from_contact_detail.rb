class RenameTypeAndSubtypeFromContactDetail < ActiveRecord::Migration
  def change
  	rename_column :contact_details, :type, :detail_method
  	rename_column :contact_details, :subtype, :detail_type
  end
end
