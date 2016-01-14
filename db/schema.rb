# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160114122824) do

  create_table "categorias", force: :cascade do |t|
    t.string   "nome"
    t.text     "descricao"
    t.boolean  "ativo"
    t.string   "url"
    t.string   "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publicacoes", force: :cascade do |t|
    t.string   "titulo"
    t.text     "descricao"
    t.integer  "codigo"
    t.string   "url"
    t.string   "link_imagem"
    t.string   "caminho_imagem"
    t.integer  "situacao"
    t.boolean  "exportado"
    t.integer  "categoria_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "host"
  end

  add_index "publicacoes", ["categoria_id"], name: "index_publicacoes_on_categoria_id"

end
