class UserMailer < ActionMailer::Base
  default :from => "copypasta@credibl.es"

  def edit_status_change_notice(edit)
    @edit = edit
    mail(:to => edit.email, :subject => "Re: Proposed edit on #{edit.page.url}", :bcc => 'kurt@mubble.net')
  end
end
