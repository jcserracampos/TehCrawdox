json.array!(@hosts) do |host|
  json.extract! host, :id, :links, :imagem_padrao
  json.url host_url(host, format: :json)
end
