class Account < ActiveRecord::Base
  has_many :sites
  has_many :editors
  has_many :pages
  has_many :edits, :through => :pages

  def self.for_host(host)
    s = Site.where(:host => host).first
    if s.nil?
      s = Site.new(:host => host)
      s.account = Account.new
      s.save!
    end
    s.account
  end
end