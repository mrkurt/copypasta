class EmbedsController < ApplicationController
  layout 'copypasta'
  def index
    raise request.env['HTTP_USER_AGENT']
  end
  def show
    @account = Account.find_with_obfuscated_id(params[:id])
  end
end
