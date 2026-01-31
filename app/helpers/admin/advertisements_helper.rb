module Admin::AdvertisementsHelper
  def display_ads_for(section)
    Advertisement.active.where(placement: section)
  end
  # Example helper:
  def ad_status_badge(ad)
    ad.active? ? "badge bg-success" : "badge bg-secondary"
  end
end