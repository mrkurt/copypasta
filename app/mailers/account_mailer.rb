class AccountMailer < ActionMailer::Base
  default :from => "Kurt Mackey <kurt@credibl.es>"

  def welcome(editor)
    @editor = editor
    mail(:to => editor.email, :subject => 'Welcome to copypasta', :bcc => 'kurt@mubble.net')
  end
end
