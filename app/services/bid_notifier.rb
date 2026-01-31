class BidNotifier
  def self.notify_homeowner(bid)
    Notification.create!(
      user: bid.listing.user,
      title: "New Bid Received",
      body: "#{bid.user.name} placed a bid on '#{bid.listing.title}'",
      notification_type: "bid_received",
      data: { listing_id: bid.listing.id, bid_id: bid.id, provider_id: bid.user.id },
      url: Rails.application.routes.url_helpers.listing_path(bid.listing)  # now works
    )
  end

  def self.notify_provider_bid_accepted(bid)
    Notification.create!(
      user: bid.user,
      title: "Bid Accepted 🎉",
      body: "Your bid on '#{bid.listing.title}' was accepted",
      notification_type: "bid_accepted",
      data: { listing_id: bid.listing.id, bid_id: bid.id },
      url: Rails.application.routes.url_helpers.provider_dashboard_path
    )
  end

  def self.notify_provider_bid_rejected(bid)
    Notification.create!(
      user: bid.user,
      title: "Bid Not Selected",
      body: "Your bid on '#{bid.listing.title}' was rejected",
      notification_type: "bid_rejected",
      data: { listing_id: bid.listing.id, bid_id: bid.id, provider_id: bid.user.id },
      url: Rails.application.routes.url_helpers.provider_dashboard_path
    )
  end

  def self.notify_homeowner_bid_withdrawn(bid)
    Notification.create!(
      user: bid.listing.user,
      title: "Bid Withdrawn",
      body: "#{bid.user.name} withdrew their bid on '#{bid.listing.title}'",
      notification_type: "bid_withdrawn",
      data: { listing_id: bid.listing.id, bid_id: bid.id },
      url: Rails.application.routes.url_helpers.listing_path(bid.listing)
    )
  end
end
