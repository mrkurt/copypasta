class Site < ActiveRecord::Base
  belongs_to :account
  validates_uniqueness_of :host
end
