class Email < ActiveRecord::Base
  validates_uniqueness_of :digest

  before_validation :ensure_digest

  def ensure_digest
    return unless digest.nil?
    self.digest = Digest::MD5.hexdigest(raw)
  end

  def self.config
    @config ||= {:password => ENV['COPYPASTA_EMAIL_PASSWORD'], :email => ENV['COPYPASTA_EMAIL']}
  end
end
