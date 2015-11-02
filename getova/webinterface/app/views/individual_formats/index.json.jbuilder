json.array!(@individual_formats) do |individual_format|
  json.extract! individual_format, :id, :name, :baseToFormat, :formatToBase
  json.url individual_format_url(individual_format, format: :json)
end
