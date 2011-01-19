class EditObserver < ActiveRecord::Observer
  def after_create(edit)
    edit.page.account.editors.each do |editor|
      EditorMailer.new_edit_notice(edit, editor).deliver
    end
  end

  def after_update(edit)
    changes = edit.changes
    if changes['status']
      UserMailer.edit_status_change_notice(edit) unless edit.email.blank?
      if edit.email.blank?
        puts "Edit #{edit.id} had no email"
      end
    else
      puts "No changes in status, skipping email"
    end
  end
end
