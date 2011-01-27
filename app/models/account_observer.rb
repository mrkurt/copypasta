class AccountObserver < ActiveRecord::Observer
  def after_create(account)
    account.editors.where(:is_owner => true).each do |e|
      AccountMailer.welcome(e).deliver
    end
  end
end
