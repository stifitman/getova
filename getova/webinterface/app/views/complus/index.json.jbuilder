json.array!(@complus) do |complu|
  json.extract! complu, :id, :data
  json.url complu_url(complu, format: :json)
end
