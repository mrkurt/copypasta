class OwnerFlagOnEditor < ActiveRecord::Migration
  def self.up
    add_column :editors, :is_owner, :boolean, :default => false
    remove_column :accounts, :owner_email
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
