class CreateEditorTokens < ActiveRecord::Migration
  def self.up
    create_table :editor_tokens do |t|
      t.belongs_to :editor
      t.string :key
      t.datetime :expires_at
      t.integer :use_count, :default => 0
      t.timestamps
    end

    add_index(:editor_tokens, :key, :unique => true)
  end

  def self.down
    drop_table :editor_tokens
  end
end
