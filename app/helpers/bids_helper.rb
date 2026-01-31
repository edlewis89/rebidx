module BidsHelper
  def bid_badge_class(bid)
    case bid.status.to_sym
    when :pending
      "bg-secondary"
    when :accepted
      "bg-success"
    when :awarded
      "bg-warning text-dark"   # Homeowner awarded, waiting payment/start
    when :paid
      "bg-info"                # Payment completed, work can start
    when :complete
      "bg-success"             # Work done
    when :rejected
      "bg-danger"
    when :withdrawn
      "bg-dark"
    else
      "bg-light text-dark"
    end
  end

  def bid_badge_label(bid)
    icon =
      case bid.status.to_sym
      when :pending then "🕒"
      when :accepted then "✅"
      when :awarded then "🏆"
      when :paid then "💰"
      when :complete then "🏁"
      when :rejected then "❌"
      when :withdrawn then "⚪"
      else "📄"
      end

    "#{icon} #{bid.status.humanize}"
  end
end