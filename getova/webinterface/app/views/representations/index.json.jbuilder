json.array!(@representations) do |representation|
  json.extract! representation, :id, :individual_id, :content, :format_id
  json.url representation_url(representation, format: :json)
end
