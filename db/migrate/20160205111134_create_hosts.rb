class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.string :links
      t.text :imagem_padrao

      t.timestamps null: false
    end
  end
end
