class EmbedsController < ApplicationController
  layout 'copypasta'
  def show
    @account = Account.find_with_obfuscated_id(params[:id])
  end
end
