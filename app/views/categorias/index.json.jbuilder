json.array!(@categorias) do |categoria|
  json.extract! categoria, :id, :nome, :descricao, :ativo, :url, :path
  json.url categoria_url(categoria, format: :json)
end
