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
    setcookie 'email', @edit.email
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

  def edit
    @edit = Edit.find(params[:id])
    raise "No yuo!" unless is_editor_for?(@edit.page)
  end

  def update
    @edit = Edit.find(params[:id])
    raise "No yuo!" unless is_editor_for?(@edit.page)
    mail_options = {}
    @edit.status = params[:edit][:status] if params[:edit][:status]
    if @edit.changes['status']
      mail_options[:old_status] = @edit.changes['status'].first
    end

    @edit.update_attributes!(params[:edit])

    UserMailer.edit_status_change_notice(@edit) unless @edit.email.blank?

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
    @edit.user_name = cookies["user_name"]
    @edit.email = cookies["email"]
    @edit.url = params[:url] if @edit.url.blank?
    render :layout => (params[:view] || true)
  end

end
