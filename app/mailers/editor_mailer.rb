class EditorMailer < ActionMailer::Base
  default :from => "copypasta <copypasta@credibl.es>"
  layout 'editor_email'
  helper :edits

  def new_edit_notice(edit, editor)
    @edit = edit
    @editor = editor
    from = "copypasta <copypasta+edit-#{edit.id}-#{edit.key}@credibl.es>"

    mail(:to => editor.email, :from => from, :subject => "Corrections for #{edit.page.url}", :bcc => 'kurt@mubble.net')
  end

  def edit_message(edit, editor, options = {})
    @options = options
    @edit = edit
    name = options[:from_name]
    name = 'copypasta' if name.blank?

    from = "#{name} <copypasta+edit-#{edit.id}-#{edit.key}@credibl.es>"

    mail(:to => editor.email, :from => from, :subject => "Re: Corrections for #{edit.page.url}", :bcc => 'kurt@mubble.net')
  end

  def receive(email)
    addr = ReceivedEmail.parse_address(email.to.join(","))
    return unless addr && addr[:id]

    e = Edit.where(:id => addr[:id]).first
    return if e.nil?
    options = {}
    options[:from_name] = email[:from].display_names.join(",")
    body = (email.text_part && email.text_part.body.to_s) || email.body.to_s

    if addr[:key].blank? #user response
      options[:message] = body
      e.page.account.editors.each do |editor|
        Rails.logger.info("EditorMailer: Sending user response on #{e.id} to #{editor.email}")
        EditorMailer.edit_message(e, editor, options).deliver
      end
      true
    else #editor response
      ins = ReceivedEmail.parse_body(body, addr[:key])
      if e && addr[:key] == e.key
        options[:message] = ins[:message]
        unless ins[:status].blank? || ins[:status] == e.status
          options[:old_status] = e.status
          e.status = ins[:status]
          Rails.logger.info "EditorMailer: Updating status on edit #{e.id}: #{ins[:status]}"
          e.save!
        end

        unless e.email.blank?
          Rails.logger.info("EditorMailer: Sending editor response on #{e.id} to #{e.email}")
          UserMailer.edit_status_change_notice(e, options).deliver
        end
        true
      elsif e && addr[:key] != e.key
        Rails.logger.info "EditorMailer: Key for #{e.id} didn't match: #{addr[:key]}"
        false
      elsif e.nil?
        Rails.logger.info "EditorMailer: Can't find edit #{addr[:id]}, ignoring email"
        false
      end
    end
  end
end
