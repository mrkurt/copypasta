class CreateEditors < ActiveRecord::Migration
  def self.up
    create_table :editors do |t|
      t.string :email
      t.string :host
      t.string :key
      t.timestamps
    end

    add_index(:editors, :host)
  end

  def self.down
    drop_table :editors
  end
end
