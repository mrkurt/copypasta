class Editor < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :key
  validates :email, :presence => true, :email => true

  before_validation :generate_key

  def create_token(expires = 1.day.from_now)
    EditorToken.create!(:editor => self, :expires_at => expires)
  end

  def generate_key
    return unless key.nil?
    self.key = ActiveSupport::SecureRandom.hex(20)
  end
end
