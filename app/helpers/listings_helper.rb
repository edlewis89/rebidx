module ListingsHelper
  # Returns the bootstrap badge class based on listing status
  def listing_badge_class(listing, provider: nil)
    # Locked state for providers
    if provider && !AccessGate.new(provider).can_bid_on_listing?(listing)
      return "bg-secondary text-white" # Locked listings
    end

    case listing.status.to_sym
    when :open
      "bg-secondary"                # Available
    when :awarded
      "bg-warning text-dark"        # Winner chosen, awaiting payment/start
    when :in_progress
      "bg-primary"                  # Actively being worked
    when :complete
      "bg-success"                  # Finished successfully
    when :cancelled
      "bg-danger"                   # Cancelled / failed
    when :expired
      "bg-warning text-dark"        # Time ran out
    when :withdrawn
      "bg-light text-dark"          # Bid withdrawn / listing withdrawn
    else
      "bg-light text-dark"
    end
  end

  # Returns the badge label including icon
  def listing_badge_label(listing, provider: nil)
    # Locked state
    # if provider && !AccessGate.new(provider).can_bid_on_listing?(listing)
    #   return "🔒 Locked"
    # end

    icon =
      case listing.status.to_sym
      when :open then "🟢"
      when :awarded then "🏆"
      when :in_progress then "🔧"
      when :complete then "✅"
      when :cancelled then "❌"
      when :expired then "⏰"
      when :withdrawn then "🚫"
      else "📄"
      end

    # Special icon if listing is Custom / Other
    if listing.services.map(&:name).include?("Custom / Other")
      icon = "⚠️"
    end

    "#{icon} #{listing.status.humanize}"
  end
end