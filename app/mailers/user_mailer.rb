class UserMailer < ActionMailer::Base
  default :from => "copypasta@credibl.es"
  helper :edits

  def edit_status_change_notice(edit)
    @edit = edit
    from = "copypasta <copypasta+edit-#{edit.id}@credibl.es>"
    mail(:to => edit.email, :from => from, :subject => "Re: Proposed edit on #{edit.page.url}", :bcc => 'kurt@mubble.net')
  end
end
