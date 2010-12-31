class UserInfoOnEdits < ActiveRecord::Migration
  def self.up
    add_column :edits, :email, :string
    add_column :edits, :user_name, :string
  end

  def self.down
    remove_column :edits, :email
    remove_column :edits, :user_name
  end
end
