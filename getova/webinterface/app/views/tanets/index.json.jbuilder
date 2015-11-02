json.array!(@tanets) do |tanet|
  json.extract! tanet, :id, :data
  json.url tanet_url(tanet, format: :json)
end
