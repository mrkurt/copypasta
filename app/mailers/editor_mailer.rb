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

  def receive(email)
    addr = ReceivedEmail.parse_address(email.to.join(","))
    return unless addr

    if addr[:key].nil? #user response

    else #editor response
      e = Edit.where(:id => addr[:id]).first
      ins = ReceivedEmail.parse_body(email.text_part.body.to_s, addr[:key])

      if e && addr[:key] == e.key
        e.status = ins[:status]
        e.last_message = ins[:message]
        e.status = ins[:status] if ins[:status]
        e.save!
      elsif e && addr[:key] != e.key
        Rails.logger.info "Key for #{e.id} didn't match: #{addr[:key]}"
      elsif e.nil?
        Rails.logger.info "Can't find edit #{addr[:id]}, ignoring email"
      end
    end
  end
end
