class EditsController < ApplicationController
  before_filter :require_account!, :only => [:new, :create]

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
    session["email"] = @edit.email
    session["user_name"] = @edit.user_name
    @edit.page = @page
    if @edit.save
      view = 'edits/create'
    else
      @errors = @edit.errors
      view = 'edits/new'
    end
    render view, :layout => (params[:view] || true)
  end

  def update
    @edit = Edit.find(params[:id])
    raise "No yuo!" unless is_editor_for?(@edit.page.host)
    @edit.status = params[:edit][:status] if params[:edit][:status]
    @edit.update_attributes!(params[:edit])

    render :layout => (params[:view] || true)
  end

  def new
    headers['Cache-Control'] = 'no-cache'
    @page = load_page
    @edit = Edit.new(params[:edit])
    @edit.user_name = session["user_name"]
    @edit.email = session["email"]
    @edit.url = params[:url] if @edit.url.blank?
    render :layout => (params[:view] || true)
  end

  def load_page(create = false)
    return @page if @page
    return nil unless (params[:page] && !params[:page][:key].blank?) || params[:url]
    key = (params[:page] && !params[:page][:key].blank?) ? params[:page][:key] : Digest::MD5.hexdigest(params[:url])
    @page = Page.where(:key => key, :account_id => account.id).first
    unless @page
      @page = Page.new(params[:page])
      @page.account = account
      @page.key = key
      @page.url = params[:url]
      @page.save if create
    end
    @page
  end

end
