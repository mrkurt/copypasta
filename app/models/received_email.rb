require 'net/imap'
class ReceivedEmail < Email
  def self.parse_address(e)
    if e =~ EDIT_ADDRESS_REGEX
      {:id => $1, :key => $2 }
    end
  end

  EDIT_ADDRESS_REGEX = /copypasta\+edit-(\d+)-?(([a-z0-9]+))?@credibl\.es/
  STATUS_REGEX = /^[^\n]*\[\s*x\s*\]\s(\w+)/m 
  INSTRUCTIONS_REGEX = /(.*)^[^\n]*\*{3}copypasta\sinstructions\*{3}[^\n]*\n(.*)/m
  EMAIL_SANITIZE_REGEX = /copypasta(\+|%2B)edit-(\d+)-\w+\@credibl\.es/
  def self.parse_body(body, key)
    result = {}
    ins = false
    if body =~ INSTRUCTIONS_REGEX
      ins = result[:instructions] = $2
      body = $1
    end
    if ins && ins =~ STATUS_REGEX
      result[:status] = $1 + 'ed'
    end
    if key
      result[:message] = body.gsub(/-?#{key}/, '')
    end
    result
  end

  def self.check_mail
    # make a connection to imap account
    imap = Net::IMAP.new('imap.gmail.com', 993, true)
    imap.login(Email.config['username'], Email.config['password'])
    # select inbox as our mailbox to process
    imap.select('Inbox')
    
    # get all emails that are in inbox that have not been deleted
    imap.uid_search(["NOT", "DELETED"]).each do |uid|
      # fetches the straight up source of the email for tmail to parse
      source = imap.uid_fetch(uid, ['RFC822']).first.attr['RFC822']

      EditorMailer.receive(source)

      # there isn't move in imap so we copy to new mailbox and then delete from inbox
      imap.uid_copy(uid, "[Gmail]/All Mail")
      imap.uid_store(uid, "+FLAGS", [:Deleted])
    end
    
    # expunge removes the deleted emails
    imap.expunge
    imap.logout
    imap.disconnect
  end
end
