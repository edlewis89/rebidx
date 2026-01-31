module ListingsHelper
  def listing_badge_class(listing)
    case listing.status.to_sym
    when :open
      "bg-secondary"  # Available
    when :awarded
      "bg-warning text-dark"  # Winner chosen, awaiting payment/start
    when :in_progress
      "bg-primary"    # Actively being worked
    when :complete
      "bg-success"    # Finished successfully
    when :cancelled
      "bg-danger"     # Cancelled / failed
    when :expired
      "bg-warning text-dark"  # Time ran out
    else
      "bg-light text-dark"
    end
  end

  def listing_badge_label(listing)
    icon =
      case listing.status.to_sym
      when :open then "🟢"
      when :awarded then "🏆"
      when :in_progress then "🔧"
      when :complete then "✅"
      when :cancelled then "❌"
      when :expired then "⏰"
      else "📄"
      end

    "#{icon} #{listing.status.humanize}"
  end
end