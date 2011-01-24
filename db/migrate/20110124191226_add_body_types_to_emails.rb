class AddBodyTypesToEmails < ActiveRecord::Migration
  def self.up
    rename_column :emails, :body, :body_text
    add_column :emails, :body_html, :text
  end

  def self.down
    rename_column :emails, :body_text, :body
    remove_column :emails, :body_html
  end
end
