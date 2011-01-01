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
end
