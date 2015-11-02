json.array!(@individuals) do |individual|
  json.extract! individual, :id, :name
  json.url individual_url(individual, format: :json)
end
