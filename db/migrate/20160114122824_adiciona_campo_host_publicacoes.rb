class AdicionaCampoHostPublicacoes < ActiveRecord::Migration
  def change

    add_column :publicacoes, :host, :string

  end
end
