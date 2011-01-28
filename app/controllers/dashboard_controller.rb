class DashboardController < ApplicationController
  def check_mail
    ReceivedEmail.check_mail
    render :text => 'done'
  end
end
