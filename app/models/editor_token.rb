class EditorToken < ActiveRecord::Base
  belongs_to :editor
  validates_presence_of :editor_id, :expires_at
  validates_uniqueness_of :key

  after_validation :generate_key

  def generate_key
    if key.nil?
      self.key = ::BCrypt::Password.create("#{editor_id}#{expires_at}#{editor.key}")
    end
  end
end
