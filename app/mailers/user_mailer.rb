class UserMailer < ActionMailer::Base
  default :from => "copypasta@credibl.es"
  helper :edits

  def edit_status_change_notice(edit, options = {})
    @edit = edit
    @options = options
    name = options[:from_name]
    name = 'copypasta' if name.blank?
    from = "#{name} <copypasta+edit-#{edit.id}@credibl.es>"
    mail(:to => edit.email, :from => from, :subject => "Re: Proposed edit on #{edit.page.url}", :bcc => 'kurt@mubble.net')
  end
end
