class ApplicationController < ActionController::Base
  protect_from_forgery

  def require_url!
    raise "No URL specified" unless params[:url]
  end

  def host
    return @host if @host
    raise "No URL specified" unless params[:url]
    u = URI.parse params[:url]
    raise "No URL specified" unless u.host
    @host = u.host
  end

  def is_editor_for?(host)
    t = session["editor_key_#{host}"]
    return false if t.nil?
    EditorToken.where(:key => t).first || false
  end
end
