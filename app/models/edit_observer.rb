class EditObserver < ActiveRecord::Observer
  def after_create(edit)
    edit.page.account.editors.each do |editor|
      EditorMailer.new_edit_notice(edit, editor).deliver
    end
  end
end
