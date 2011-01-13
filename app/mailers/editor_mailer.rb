class EditorMailer < ActionMailer::Base
  default :from => "copypasta@credibl.es"

  def new_edit_notice(edit, editor)
    @edit = edit
    @editor = editor

    mail(:to => editor.email, :subject => "Corrections for #{edit.page.url}", :bcc => 'kurt@mubble.net')
  end
end
