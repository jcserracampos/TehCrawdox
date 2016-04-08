class AlteraCampoLinks < ActiveRecord::Migration
  def change
    remove_column :hosts, :links
    add_column :hosts, :url, :string
  end
end
