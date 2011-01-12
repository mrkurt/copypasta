class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.belongs_to :account
      t.string :host
      t.timestamps
    end
  end

  def self.down
    drop_table :sites
  end
end
