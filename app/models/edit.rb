class Edit < ActiveRecord::Base
  xss_foliate :strip => [:original, :proposed]
  attr_accessible :element_path, :original, :proposed, :url, :email, :user_name, :opt_in

  belongs_to :page

  validates_inclusion_of :status, :in => ['new', 'rejected', 'accepted']
  validates_presence_of :proposed, :original, :url
  validates :email, :email => true, :required => true

  validate :proposed_should_be_different
  before_save :calculate_distance
  before_save :generate_key

  def last_message
    @last_message
  end

  def last_message=(msg)
    @last_message = msg
  end
  
  def proposed_should_be_different
    errors[:proposed] << 'fix must have changes' if proposed == original
  end

  def url_with_edits
    url + '#copypasta-auto'
  end

  def calculate_distance
    return unless distance.nil? || changes['original'] || changes['proposed']
    self.distance = Text::Levenshtein.distance(original, proposed)
  end

  def generate_key
    return unless key.nil?
    self.key = ActiveSupport::SecureRandom.hex(6)
  end
end
