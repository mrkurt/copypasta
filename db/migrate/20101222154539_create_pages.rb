class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :host
      t.string :key
      t.string :url
      t.timestamps
    end

    add_index(:pages, [:host, :key], :unique => true)
  end

  def self.down
    drop_table :pages
  end
end
