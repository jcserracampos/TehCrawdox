require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

namespace :mechanize do

  task cpturbo_categorias: :environment do
    cpturbo_logar
    categorias_cpturbo
  end

  task cpturbo_publicacoes: :environment do
    cpturbo_logar
    cpturbo_publicacoes
  end

  def cpturbo_logar
    puts 'Logando'
    cpturbo = AGENTE.get('http://www.cpturbo.org/')
    formulario = cpturbo.form()
    formulario.ips_username = 'USUARIO'
    formulario.ips_password = 'SENHA'
    cpturbo = AGENTE.submit(formulario, formulario.buttons.first)
    puts 'Usuário logado'
  end

  def categorias_cpturbo
    regex = Regexp.new('(http:\/\/www.cpturbo.org\/cpt\/index\.php\?showforum=[0-9]{1,4})')
    cpturbo = AGENTE.get('http://www.cpturbo.org/cpt/index.php?act=idx')
    categorias = []
    cpturbo.links.each do |link|
      if regex.match(link.uri.to_s)
        categorias << regex.match(link.uri.to_s).to_s
      end
    end

    categorias.each do |categoriaAuxiliar|
      begin
        categoriaAuxiliar = AGENTE.get(categoriaAuxiliar)
      rescue Mechanize::ResponseCodeError => exception
        if exception.response_code == '404'
          puts 'Categoria não encontrada '+categoriaAuxiliar.to_s
        else
          puts exception.response_code # Some other error, re-raise
        end
      else
        categoriaSalvar = Categoria.new
        categoriaSalvar.nome = categoriaAuxiliar.title
        puts 'Categoria localizada '+categoriaSalvar.nome

        # TODO Capturar a descrição.
        categoriaSalvar.ativo = false
        categoriaSalvar.url = categoriaAuxiliar.uri.to_s
        # FAZER capturar o nome até o hífen
        categoriaSalvar.path = /\w+/.match(categoriaSalvar.nome).to_s

        unless Categoria.where(nome: categoriaSalvar.nome).exists?
          puts 'Categoria adicionada '+categoriaSalvar.nome
          categoriaSalvar.save
        end
      end
    end
  end

  def cpturbo_publicacoes
    regex = Regexp.new('(http:\/\/www.cpturbo.org\/cpt\/index\.php\?showtopic=[0-9]{1,8})')
    # Busca apenas nas categorias marcadas como ativas
    categorias = Categoria.where(ativo: true)
    categorias.each do |categoria|
      categoria_pagina = AGENTE.get(categoria.url)
      categoria_pagina.links.each do |link|
        @links << regex.match(link.uri.to_s).to_s if regex.match(link.uri.to_s)
      end
    end
    puts 'Processando publicações'
    @links.each do |pub|
      pubPagina = AGENTE.get(pub)
      unless Publicacao.where(titulo: pubPagina.title).exists?
        publicacao = Publicacao.new
        publicacao.titulo = pubPagina.title
        puts 'Publicação capturada '+publicacao.titulo
        publicacao.codigo = /\d+/.match(pub).to_s
        publicacao.url = pub
        publicacao.situacao = '1'
        publicacao.exportado = false
        publicacao.categoria_id = '1'
        publicacao.conteudo_html = AGENTE.get(publicacao.url).parser.css('.post.entry-content').to_s.force_encoding('iso-8859-1').encode('utf-8')

        downloads = []

        Nokogiri::HTML(publicacao.conteudo_html).css('.prettyprint').first.to_s.scan(/[a-z]{3,5}:\/\/[^\s"<\\']*/).each do |link|
          downloads << link
        end

        Nokogiri::HTML(publicacao.conteudo_html).css('.bbc_url').to_s.scan(/[a-z]{3,5}:\/\/[^\s"<\\']*/).each do |link|
          link = link[30...link.length]
          downloads << link
        end

        downloads.each do |link|
          unless /http:\/\/www.cpturbo.org/.match(link)
            l = publicacao.links.new
            l.link = link
            if Host.where(url: /[a-z]{3,5}:\/\/[a-zA-Z0-9.]+/.match(link).to_s).exists?
              host = Host.where(url: /[a-z]{3,5}:\/\/[a-zA-Z0-9.]+/.match(link).to_s)
              # Fazer: Localizar o host corretamente
              l.host = host
            else
              agent = Mechanize.new
              host = Host.new
              host.url = /[a-z]{3,5}:\/\/[a-zA-Z0-9.]+/.match(link).to_s
              begin
                pagina = agent.get(host.url)
              rescue Mechanize::ResponseCodeError
                puts 'Site indisponível '
              rescue Mechanize::SocketError
                puts 'Url capturada do host está com problema'
                  next
              else
                host.imagem_padrao = pagina.images[0]
                host.titulo = pagina.title.to_s
                host.ativo = true
                # Fazer: Salvar o host somente junto com uma publicação nova
                host.save!
              end
              # Fazer: Detectar o host corretamente
              l.host = host
            end
          end
        end
        if publicacao.save
          puts 'Publicação salva '+publicacao.titulo
        end
      end
    end
  end
end
