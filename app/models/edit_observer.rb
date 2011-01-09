class EditObserver < ActiveRecord::Observer
  def after_create(edit)
    Editor.where(:host => edit.page.host).each do |editor|
      edit.logger.info "Edit created, notifying #{editor.email}"
      EditorMailer.new_edit_notice(edit, editor).deliver
    end
  end
end
