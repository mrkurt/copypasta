class Editor < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :key
  validates_uniqueness_of :email, :scope => :account_id

  def create_token(expires = 1.day.from_now)
    EditorToken.create!(:editor => self, :expires_at => expires)
  end
end
