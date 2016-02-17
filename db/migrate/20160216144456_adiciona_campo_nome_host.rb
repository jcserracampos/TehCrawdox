class AdicionaCampoNomeHost < ActiveRecord::Migration
  def change
    add_column :hosts, :titulo, :string
    add_column :hosts, :ativo, :boolean
  end
end
