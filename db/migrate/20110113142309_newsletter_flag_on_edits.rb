class NewsletterFlagOnEdits < ActiveRecord::Migration
  def self.up
    add_column :edits, :opt_in, :boolean, :default => false
  end

  def self.down
    remove_column :edits, :opt_in
  end
end
