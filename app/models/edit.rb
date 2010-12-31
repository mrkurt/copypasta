class Edit < ActiveRecord::Base
  xss_foliate :strip => [:original, :proposed]
  attr_accessible :element_path, :original, :proposed, :url, :email, :user_name

  belongs_to :page

  validates_inclusion_of :status, :in => ['new', 'rejected', 'applied']
  validates_presence_of :proposed, :original, :url

  validate :proposed_should_be_different

  def proposed_should_be_different
    errors[:proposed] << 'fix must have changes' if proposed == original
  end
end
