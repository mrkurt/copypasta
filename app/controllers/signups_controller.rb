class SignupsController < ApplicationController
  layout 'copypasta'
  def show
    @account = Account.new(params[:account])
    @editor = Editor.new(params[:editor])
  end

  def shhh
    render :layout => false
  end
end
