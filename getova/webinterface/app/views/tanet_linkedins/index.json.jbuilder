json.array!(@tanet_linkedins) do |tanet_linkedin|
  json.extract! tanet_linkedin, :id, :name, :data
  json.url tanet_linkedin_url(tanet_linkedin, format: :json)
end
