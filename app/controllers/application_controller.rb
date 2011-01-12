class ApplicationController < ActionController::Base
  protect_from_forgery

  def require_account!
    raise "You must supply either an account ID or a URL" if account.nil?
  end

  def host
    return @host if @host
    return nil unless params[:url]
    u = URI.parse params[:url]
    @host = u.host
  end

  def account
    return @account if @account

    @account = Account.find(params[:account_id]) if params[:account_id]
    if @account.nil? && !(h = host).nil?
      @account = Account.for_host(h)
    end
    @account
  end

  def is_editor_for?(account)
    t = session["editor_key_#{account.id}"]
    return false if t.nil?
    EditorToken.where(:key => t).first || false
  end
end
