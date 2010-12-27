class CreateEdits < ActiveRecord::Migration
  def self.up
    create_table :edits do |t|
      t.string :url
      t.string :element_path
      t.text :original
      t.text :proposed
      t.string :status, :default => 'new'
      t.string :ip_address
      t.references :page
      t.timestamps
    end

    add_index(:edits, :page_id)
  end

  def self.down
    drop_table :edits
  end
end
