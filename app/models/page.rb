class Page < ActiveRecord::Base
  belongs_to :account
  validates_uniqueness_of :key, :scope => :account_id

  has_many :edits
end
