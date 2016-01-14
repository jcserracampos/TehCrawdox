class CreatePublicacoes < ActiveRecord::Migration
  def change
    create_table :publicacoes do |t|
      t.string :titulo
      t.text :descricacao
      t.integer :codigo
      t.string :url
      t.string :link_imagem
      t.string :caminho_imagem
      t.integer :situacao
      t.boolean :exportado
      t.references :categoria, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
