module Admin::VerificationsHelper
  def status_color(status)
    case status
    when "verified" then "success"
    when "pending" then "warning"
    when "rejected" then "danger"
    else "secondary"
    end
  end
end
