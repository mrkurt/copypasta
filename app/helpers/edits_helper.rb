module EditsHelper
  def diff_edit(edit = nil, escape = true)
    edit ||= @edit
    o = edit.original
    p = edit.proposed
    o = h o if escape
    p = h p if escape
    HTMLDiff.diff(o, p)
  end

  def edit_time(edit = nil)
    edit ||= @edit
    time_ago_in_words edit.created_at
  end
  
  def edit_author(edit = nil)
    edit ||= @edit
    if edit.user_name.blank?
      "(Anonymous)"
    else
      edit.user_name
    end
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
end
