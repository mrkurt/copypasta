class EditDistance < ActiveRecord::Migration
  def self.up
    add_column :edits, :distance, :integer
    Edit.where(:distance => nil).each(&:save)
  end

  def self.down
    remove_column :edits, :distance
  end
end
