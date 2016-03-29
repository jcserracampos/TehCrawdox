require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

namespace :importacao do
  agente = Mechanize.new # Cria um novo agente do Mechanize que será utilizado em toda a tarefa.
  agente.follow_meta_refresh = true # Segue o encaminhamento da página

  task mechanize: :environment do
    logarforum
  end

  def logarForum
    puts "Logando"
    pagina = agente.get('http://www.tehparadox.com')
    formulario = pagina.form()
    # TODO: Criar um usuário para não utilizar o meu /JC
    # Preenche o formulário de login
    formulario.vb_login_username = 'zapattavilla'
    formulario.vb_login_password = 'Embraceurdreams1!'
    # Submete o formulário de login
    pagina = agente.submit(formulario, formulario.buttons.first)
    # Se o follow_meta não funcionar, redireciono para a página inicial de novo manualmente
    pagina = agente.get('http://www.tehparadox.com')
    puts "Usuário logado"
  end

  def buscarCategorias
    # Acessa a página que contém todas as categorias
    categoriaPagina = agente.get("http://www.tehparadox.com/forum")
    # Percorre
    categorias = []
    categoriaPagina.links.each do |link|
      if /(http:\/\/tehparadox.com\/forum\/f[0-9]{1,2})/.match(link.uri.to_s)
        categorias << /(http:\/\/tehparadox.com\/forum\/f[0-9]{1,2})/.match(link.uri.to_s).to_s
      end
    end

    categorias.each do |categoriaAuxiliar|
      categoriaAuxiliar = agente.get(categoriaAuxiliar)
      categoriaSalvar = Categoria.new
      categoriaSalvar.nome = categoriaAuxiliar.title
      # TODO Capturar a descrição.
      categoriaSalvar.ativo = true
      categoriaSalvar.url = categoriaAuxiliar.uri.to_s
      categoriaSalvar.path = /\w+/.match(categoriaSalvar.nome).to_s

      unless Categoria.where(nome: categoriaSalvar.nome).exists?
        categoriaSalvar.save
      end
    end
  end

  def buscarLinks
    # Buscar apenas nas categorias consideradas ativas
    categorias = Categoria.where(ativo: true)

    categorias.each do |categoria|
      categoriaPagina = agente.get(categoria.url)
      if id = categoriaPagina.links.index(categoriaPagina.link_with(dom_id: "thread_title_4026461"))
        loop do

          break if a
        end
        id = id + 3
        publicacao = Nokogiri::HTML(open(categoriaPagina.links[id].uri.to_s))
        # Traz o conteúdo da publicação
        publicacaoDescricao = publicacao.css('.post')
        # TODO Obter título, descrição, código, url e conteúdo
        # Traz o que tem dentro de um campo CODE | Geralmente os links
        publicacaoLinks = descricao_publicacao.css('.alt2').to_s
      end
    end
  end
end