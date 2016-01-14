class AlterarCampoDescricao < ActiveRecord::Migration
  def change
    rename_column :publicacoes, :descricacao, :descricao
  end
end
