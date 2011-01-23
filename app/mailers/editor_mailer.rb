class EditorMailer < ActionMailer::Base
  default :from => "copypasta@credibl.es"
  layout 'editor_email'
  helper :edits

  def new_edit_notice(edit, editor)
    @edit = edit
    @editor = editor
    from = "copypasta <copypasta+edit-#{edit.id}-#{edit.key}@credibl.es>"

    mail(:to => editor.email, :from => from, :subject => "Corrections for #{edit.page.url}", :bcc => 'kurt@mubble.net')
  end
end
