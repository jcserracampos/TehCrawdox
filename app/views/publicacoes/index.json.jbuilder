json.array!(@publicacoes) do |publicacao|
  json.extract! publicacao, :id, :titulo, :descricacao, :codigo, :url, :link_imagem, :caminho_imagem, :situacao, :exportado, :categoria_id
  json.url publicacao_url(publicacao, format: :json)
end
