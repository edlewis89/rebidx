Geocoder.configure(

  # Geocoding service
  lookup: :nominatim,

  # Timeout in seconds
  timeout: 5,

  # Units
  units: :mi, # miles (important for US marketplace)

  # Cache results to reduce API calls
  cache: Rails.cache,

  # Use HTTPS
  use_https: true,

  # Do not raise exceptions on failure
  always_raise: [],

  # Logging
  logger: Rails.logger,

  http_headers: { "User-Agent" => "RebidxApp/1.0 (lewiedw89@gmail.com)" },

)


# Production
# Geocoder.configure(
#   lookup: :nominatim,
#   timeout: 5,
#   units: :mi,
#   cache: Rails.cache,
#   use_https: true,
#   http_headers: {
#     "User-Agent" => "RebidxApp"
#   },
#   always_raise: [],
#   logger: Rails.logger
# )