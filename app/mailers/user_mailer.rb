class UserMailer < ActionMailer::Base
  default :from => "copypasta@credibl.es"

  def edit_status_change_notice(edit)
    return if edit.email.blank?
    @edit = edit
    mail(:to => edit.email, :subject => "Your edit on #{edit.page.url}", :bcc => 'kurt@mubble.net')
  end
end
