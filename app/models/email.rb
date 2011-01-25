class Email < ActiveRecord::Base
  validates_uniqueness_of :digest

  before_validation :ensure_digest

  def ensure_digest
    return unless digest.nil?
    self.digest = Digest::MD5.hexdigest(raw)
  end

  def self.config
    unless @config
      config = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))
      @config = config[Rails.env]
    end
    @config ||= {}
  end
end
