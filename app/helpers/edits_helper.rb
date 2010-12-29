module EditsHelper
  def diff_edit(edit = nil)
    edit ||= @edit
    HTMLDiff.diff(h(edit.original), h(edit.proposed))
  end
end
