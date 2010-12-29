class EditsController < ApplicationController
  protect_from_forgery :except => :new
  def show
    @edit = Edit.find(params[:id])
    render :layout => (params[:view] || true)
  end
  def create
    @edit = Edit.new(params[:edit])
    if @edit.save
      view = 'edits/create'
    else
      @errors = @edit.errors
      view = 'edits/new'
    end
    render view, :layout => (params[:view] || true)
  end

  def new
    @edit = Edit.new(params[:edit])
    @edit.url = params[:url] if @edit.url.blank?
    render :layout => (params[:view] || true)
  end
end
