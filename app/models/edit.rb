class Edit < ActiveRecord::Base
  xss_foliate :strip => [:original, :proposed]
  attr_accessible :element_path, :original, :proposed, :url

  belongs_to :page

  validates_inclusion_of :status, :in => ['new', 'rejected', 'applied']
end
