class AddExcludeFromSyncToContact < ActiveRecord::Migration
  def change
  	add_column :contacts, :exclude_from_sync, :boolean,:default => false
  end
end
