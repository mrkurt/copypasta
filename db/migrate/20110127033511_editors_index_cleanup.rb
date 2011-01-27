class EditorsIndexCleanup < ActiveRecord::Migration
  def self.up
    remove_index(:editors, [:host, :email])
  end

  def self.down
    add_index(:editors, [:host, :email], :unique => true)
  end
end
