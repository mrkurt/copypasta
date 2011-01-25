class Email < ActiveRecord::Base
  def self.from_email(email)
    body_text = nil
    if email.text_part
      body_text = email.text_part.body.to_s.encode("UTF-8", :invalid => :replace)
    end
    html_text = nil
    if email.html_part
      body_html = email.html_part.body.to_s.encode("UTF-8", :invalid => :replace)
    end
    create(:to => email.to.join(','), :from => email.from.join(','), :subject => email.subject, :body_text => body_text, :body_html => body_html)
  end

  def self.config
    unless @config
      config = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))
      @config = config[Rails.env]
    end
    @config ||= {}
  end
end
