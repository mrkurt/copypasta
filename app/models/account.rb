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

  def notify_editors(edit)
    editors.each do |editor|
      EditorMailer.new_edit_notice(edit, editor).deliver
    end
  end

  def obfuscated_id
    (self.id * self.id).to_s(36)
  end

  def self.find_with_obfuscated_id(id)
    find(Math.sqrt id.to_i(36))
  end
end
