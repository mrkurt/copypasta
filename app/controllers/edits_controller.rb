class EditsController < ApplicationController
  before_filter :require_url!, :except => :index

  def index
    @filter = params[:filter] || 'new'
    if @page = load_page
      @edits = @page.edits.where(:status => @filter)
    else
      @edits = Edit.where(:status => @filter)
    end
    render :layout => (params[:view] || true)
  end

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
    headers['Cache-Control'] = 'no-cache'
    @page = load_page
    @edit = Edit.new(params[:edit])
    @edit.url = params[:url] if @edit.url.blank?
    render :layout => (params[:view] || true)
  end

  def load_page(create = false)
    return @page if @page
    return nil unless (params[:page] && !params[:page][:key].blank?) || params[:url]
    key = (params[:page] && !params[:page][:key].blank?) ? params[:page][:key] : Digest::MD5.hexdigest(params[:url])
    @page = Page.where(:key => key, :host => host).first
    unless @page
      @page = Page.new(params[:page])
      @page.host = host
      @page.key = key
      @page.url = params[:url]
      @page.save if create
    end
    @page
  end

end
