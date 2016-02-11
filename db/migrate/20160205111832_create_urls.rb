class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.references :host, index: true, foreign_key: true
      t.string :url

      t.timestamps null: false
    end
  end
end
