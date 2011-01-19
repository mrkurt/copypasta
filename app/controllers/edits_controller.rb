class EditsController < ApplicationController
  before_filter :no_cache!
  before_filter :require_account!, :only => [:new, :create]
  before_filter :load_page

  def index
    @filter = params[:filter] || 'new'
    if @page
      @edits = @page.edits.where(:status => @filter)
    else
      @edits = Edit.where(:status => @filter).where('page_id in (select page_id from pages where account_id in (?))', editor_for)
    end
    @edits = @edits.order('id DESC')
    render :layout => (params[:view] || true)
  end

  def show
    @edit = Edit.find(params[:id])
    render :layout => (params[:view] || true)
  end

  def create
    @edit = Edit.new(params[:edit])
    session["email"] = @edit.email
    session["user_name"] = @edit.user_name
    @edit.page = @page
    @edit.ip_address = request.remote_ip
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
    raise "No yuo!" unless is_editor_for?(@edit.page.account)
    @edit.status = params[:edit][:status] if params[:edit][:status]
    @edit.update_attributes!(params[:edit])

    if @edit.status == 'rejected'
      flash[:error] = "Edit rejected"
      redirect_to (params[:return_to] || request.referer)
    else
      render :layout => (params[:view] || true)
    end
  end

  def new
    headers['Cache-Control'] = 'no-cache'
    @edit = Edit.new(params[:edit])
    @edit.user_name = session["user_name"]
    @edit.email = session["email"]
    @edit.url = params[:url] if @edit.url.blank?
    render :layout => (params[:view] || true)
  end

  def load_page
    return @page if @page
    return nil unless (params[:page] && !params[:page][:key].blank?) || params[:url]
    key = (params[:page] && !params[:page][:key].blank?) ? params[:page][:key] : Digest::MD5.hexdigest(params[:url])
    @page = Page.where(:key => key, :account_id => account.id).first
    unless @page
      @page = Page.new(params[:page])
      @page.account = account
      @page.key = key
      @page.url = params[:url]
      @page.save
    end
    @page
  end

end
