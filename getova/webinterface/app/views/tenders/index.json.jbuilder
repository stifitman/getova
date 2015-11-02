json.array!(@tenders) do |tender|
  json.extract! tender, :id, :data
  json.url tender_url(tender, format: :json)
end
