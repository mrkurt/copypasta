module EditsHelper
  def diff_edit(edit = nil, escape = true)
    edit ||= @edit
    o = edit.original
    p = edit.proposed
    o = h o if escape
    p = h p if escape
    HTMLDiff.diff(o, p)
  end

  def diff_edit_context(edit = nil, escape = true)
    edit ||= @edit
    o = edit.original
    p = edit.proposed
    o = h o if escape
    p = h p if escape
    d = HTMLDiff.diff_in_context(o,p)
  end

  def diff_edit_text(d)
    d
      .gsub(/<\/?ins( class="\w+")?>/, '+++')
      .gsub(/<\/?del( class="\w+")?>/, '---')
      .gsub('+++---', '+++ ---')
      .gsub('---+++', '--- +++')
  end

  def edit_time(edit = nil)
    edit ||= @edit
    time_ago_in_words edit.created_at
  end
  
  def edit_author(edit = nil)
    edit ||= @edit
    n = edit.user_name
    if n.blank? && !edit.email.blank?
      n = edit.email.split('@').first
    end

    n = "(Anonymous)" if n.blank?
    n
  end

  def edit_count(edits = nil)
    edits ||= @edits

    if edits.count == 0
      "No page edits yet"
    elsif edits.count == 1
      "1 page edit"
    else
      "#{edits.count} page edits"
    end
  end

  def is_editor_for?(edit = nil)
    edit ||= @edit
    controller.is_editor_for?(edit.page.account)
  end

  def edit_gravatar(edit = nil)
    edit ||= @edit

    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(edit.email)}?s=50"
  end
end
