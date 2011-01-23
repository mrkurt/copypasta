class KeyOnEdits < ActiveRecord::Migration
  def self.up
    add_column :edits, :key, :string, :length => 8
  end

  def self.down
    remove_column :edits, :key
  end
end
