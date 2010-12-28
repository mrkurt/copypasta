class EditsController < ApplicationController
  protect_from_forgery :except => :new
  def create
    @edit = Edit.create!(params[:edit])
  end

  def new
    @edit = Edit.new(params[:edit])
    @edit.url = params[:url] if @edit.url.blank?
    render :layout => (params[:view] || true)
  end
end
