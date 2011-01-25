class EditObserver < ActiveRecord::Observer
  def after_create(edit)
    edit.page.account.editors.each do |editor|
      EditorMailer.new_edit_notice(edit, editor).deliver
    end
  end

  def after_update(edit)
    if edit.changes['status'] || edit.last_message
      Rails.logger.info("Sending update notification for #{edit.id}")
      UserMailer.edit_status_change_notice(edit).deliver unless edit.email.blank?
    end
  end
end
