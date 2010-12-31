class EditsController < ApplicationController
  protect_from_forgery :except => :new
  def show
    @edit = Edit.find(params[:id])
    render :layout => (params[:view] || true)
  end
  def create
    @page = load_page(true)
    @edit = Edit.new(params[:edit])
    @edit.page = @page
    if @edit.save
      view = 'edits/create'
    else
      @errors = @edit.errors
      view = 'edits/new'
    end
    render view, :layout => (params[:view] || true)
  end

  def new
    @page = load_page
    @edit = Edit.new(params[:edit])
    @edit.url = params[:url] if @edit.url.blank?
    render :layout => (params[:view] || true)
  end

  def load_page(create = false)
    return @page if @page
    h = host
    key = (params[:page] && params[:page][:key]) || Digest::MD5.hexdigest(params[:url])
    @page = Page.where(:key => key, :host => host).first
    unless @page
      @page = Page.new(params[:page]) unless @page
      @page.host = h
      @page.key = key
      @page.url = params[:url]
      @page.save if create
    end
    @page
  end

  def host
    raise "No URL specified" unless params[:url]
    u = URI.parse params[:url]
    raise "No URL specified" unless u.host
    u.host
  end
end
