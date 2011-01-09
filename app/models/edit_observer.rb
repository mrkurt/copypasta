class EditObserver < ActiveRecord::Observer
  def after_create(edit)
    Editor.where(:host => edit.page.host).each do |editor|
      EditorMailer.new_edit_notice(edit, editor).deliver
    end
  end
end
