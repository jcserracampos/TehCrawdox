class CreateCategorias < ActiveRecord::Migration
  def change
    create_table :categorias do |t|
      t.string :nome
      t.text :descricao
      t.boolean :ativo
      t.string :url
      t.string :path

      t.timestamps null: false
    end
  end
end
