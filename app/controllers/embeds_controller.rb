class EmbedsController < ApplicationController
  layout 'copypasta'
  def index
    raise request.env.inspect
  end
  def show
    @account = Account.find_with_obfuscated_id(params[:id])
  end
end
