class AlteraPublicacoes < ActiveRecord::Migration
  def change
    remove_column :publicacoes, :link_imagem
    remove_column :publicacoes, :caminho_imagem
    remove_column :publicacoes, :host
    add_reference :publicacoes, :host, index: true, foreign_key: true
    add_column :publicacoes, :conteudo_html, :text
    add_column :publicacoes, :conteudo, :text
  end
end
