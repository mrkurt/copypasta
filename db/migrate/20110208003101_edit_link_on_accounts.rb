class EditLinkOnAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :edit_url_format, :string
  end

  def self.down
    remove_column :accounts, :edit_url_format
  end
end
