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

ActiveRecord::Schema.define(version: 20160401113618) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categorias", force: :cascade do |t|
    t.string   "nome"
    t.text     "descricao"
    t.boolean  "ativo"
    t.string   "url"
    t.string   "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hosts", force: :cascade do |t|
    t.text     "imagem_padrao"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "titulo"
    t.boolean  "ativo"
    t.string   "url"
  end

  create_table "imagens", force: :cascade do |t|
    t.integer  "publicacao_id"
    t.text     "imagem"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "imagens", ["publicacao_id"], name: "index_imagens_on_publicacao_id", using: :btree

  create_table "links", force: :cascade do |t|
    t.integer  "publicacao_id"
    t.integer  "host_id"
    t.string   "link"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "links", ["host_id"], name: "index_links_on_host_id", using: :btree
  add_index "links", ["publicacao_id"], name: "index_links_on_publicacao_id", using: :btree

  create_table "publicacoes", force: :cascade do |t|
    t.string   "titulo"
    t.text     "descricao"
    t.integer  "codigo"
    t.string   "url"
    t.integer  "situacao"
    t.boolean  "exportado"
    t.integer  "categoria_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "host_id"
    t.text     "conteudo_html"
    t.text     "conteudo"
  end

  add_index "publicacoes", ["categoria_id"], name: "index_publicacoes_on_categoria_id", using: :btree
  add_index "publicacoes", ["host_id"], name: "index_publicacoes_on_host_id", using: :btree

  create_table "urls", force: :cascade do |t|
    t.integer  "host_id"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "urls", ["host_id"], name: "index_urls_on_host_id", using: :btree

  add_foreign_key "imagens", "publicacoes"
  add_foreign_key "links", "hosts"
  add_foreign_key "links", "publicacoes"
  add_foreign_key "publicacoes", "categorias"
  add_foreign_key "publicacoes", "hosts"
  add_foreign_key "urls", "hosts"
end
