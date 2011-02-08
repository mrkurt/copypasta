class CommentOnEdits < ActiveRecord::Migration
  def self.up
    add_column :edits, :comments, :text
  end

  def self.down
    remove_column :edits, :comments
  end
end
