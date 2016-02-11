class CreateImagens < ActiveRecord::Migration
  def change
    create_table :imagens do |t|
      t.references :publicacao, index: true, foreign_key: true
      t.text :imagem

      t.timestamps null: false
    end
  end
end
