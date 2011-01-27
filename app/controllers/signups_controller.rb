class SignupsController < ApplicationController
  layout 'copypasta'
  def show
    @account = Account.new
    @editor = Editor.new
  end

  def create
    @account = Account.new
    @editor = @account.editors.build(params[:editor])
    @editor.account = @account
    @editor.is_owner = true

    if @account.save && @editor.save
      redirect_to embed_path(:id => @account.obfuscated_id)
    else
      render :show
    end
  end

  def shhh
    render :layout => false
  end
end
