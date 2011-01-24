class ReceivedEmailObserver < ActiveRecord::Observer
  def after_create(mail)
    addr = ReceivedEmail.parse_address(mail.to)
    return unless addr

    if addr[:key].nil? #user response

    else #editor response
      e = Edit.where(:id => addr[:id]).first
      ins = ReceivedEmail.parse_body(mail.body_text, addr[:key])

      if e && ins[:status] && addr[:key] == e.key
        e.status = ins[:status]
        e.last_message = ins[:message]
        e.save!
      elsif e && addr[:key] != e.key
        Rails.logger.info "Key for #{e.id} didn't match: #{addr[:key]}"
      end
    end
  end
end
