class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.references :publicacao, index: true, foreign_key: true
      t.references :host, index: true, foreign_key: true
      t.string :link

      t.timestamps null: false
    end
  end
end
