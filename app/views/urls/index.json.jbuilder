json.array!(@urls) do |url|
  json.extract! url, :id, :host_id, :url
  json.url url_url(url, format: :json)
end
