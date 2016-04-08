require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

AGENTE = Mechanize.new do |a|
  a.follow_meta_refresh = true
  a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Para evitar problemar com SSL
  # Mechanize deixa as conexões abertas e confia com coletor de lixo para limpá-las
  # Depois de um certo ponto, existem tantas conexões abertas que nenhuma conexão de saída pode ser estabelecida
  # Fazer: Fechar as conexões depois de usá-las
end


namespace :importacao do

  task capturar_publicacoes: :environment do
    logar_tehparadox
    buscar_publicacoes
    processar_publicacao
  end

  task capturar_categorias: :environment do
    logar_tehparadox
    buscar_categorias
  end

  def logar_tehparadox
    puts 'Logando'
    begin
      pagina = AGENTE.get('http://www.tehparadox.com')
    rescue Mechanize::ResponseCodeError
      puts 'Site indisponível '
      puts 'Tarefa abortada'
      exit!
    else
      formulario = pagina.form
      # TODO: Criar um usuário para não utilizar o meu /JC
      # Preenche o formulário de login
      formulario.vb_login_username = 'zapattavilla'
      formulario.vb_login_password = 'Embraceurdreams1!'
      # Submete o formulário de login
      pagina = AGENTE.submit(formulario, formulario.buttons.first)
      # Se o follow_meta não funcionar, redireciono para a página inicial de novo manualmente
      pagina = AGENTE.get('http://www.tehparadox.com')
      puts 'Usuário logado'
    end
  end

  def buscar_categorias
    regex = Regexp.new('(http:\/\/tehparadox.com\/forum\/f[0-9]{1,2})')
    # Acessa a página que contém todas as categorias
    categoria_pagina = AGENTE.get('http://www.tehparadox.com/forum')
    categorias = []
    # Percorre todos os links do fórum atrás de categorias
    categoria_pagina.links.each do |link|
      categorias << regex.match(link.uri.to_s).to_s if regex.match(link.uri.to_s)
    end

    categorias.each do |categoria_auxiliar|
      categoria_auxiliar = AGENTE.get(categoria_auxiliar)
      categoria_salvar = Categoria.new
      categoria_salvar.nome = categoria_auxiliar.title
      puts 'Categoria localizada '+categoria_salvar.nome

      # TODO Capturar a descrição.
      categoria_salvar.ativo = false
      categoria_salvar.url = categoria_auxiliar.uri.to_s
      # FAZER capturar o nome até o hífen
      categoria_salvar.path = /\w+/.match(categoria_salvar.nome).to_s

      unless Categoria.where(nome: categoria_salvar.nome).exists?
        puts 'Categoria adicionada '+categoria_salvar.nome
        categoria_salvar.save
      end
    end
  end

  def buscar_publicacoes
    last_encontrados = 0
    # Buscar apenas nas categorias consideradas ativas
    categorias = Categoria.where(ativo: true)

    categorias.each do |categoria|
      categoria_pagina = AGENTE.get(categoria.url)
      categoria_pagina.links.each do |link|
        text = link.text.strip
        href = link.href
        atributos = link.attributes

        next unless text.length > 0 ## Ignora imagens ( texto vem vazio)
        next unless href.include?(categoria[:url]) ## Ignora aqueles que não são links para a propria categoria
        next if href[-4, 4] == 'new/' ## Ignora links para "Primeiro post não lido", caso contrario fica repedito
        next if text.to_i > 0 ## Pula paginacao numeros
        if text == 'Last Page'
          if last_encontrados > 0
            break
          end
          last_encontrados += 1
          next
        end
        next if ['Last', '<', '>', 'Forum Tools', 'Forum Tools', 'Forum Tools', 'Thread', 'Thread Starter', 'Last »', '« First', 'Last Post', 'Reverse Sort Order', 'Replies',
                 'Search this Forum', 'Rating', 'Views', 'Open Contacts Popup', 'Top', 'Mark This Forum Read'].include?(text)

        @links << {texto: text, href: href, atributos: atributos, categoria: categoria}

      end
    end
  end

  def processar_publicacao
    puts 'Processando publicações'
    @links.each do |pub|
      puts pub
      unless Publicacao.where(titulo: pub[:texto]).exists?
        publicacao = Publicacao.new
        publicacao.titulo= pub[:texto].force_encoding('iso-8859-1').encode('utf-8')
        puts 'Publicação capturada '+publicacao.titulo
        publicacao.codigo = pub[:atributos][:id]
        publicacao.url = pub[:href]
        publicacao.situacao = '1'
        publicacao.exportado = false
        publicacao.imagens = Imagem.create(imagem: 'foo')
        publicacao.categoria_id = pub[:categoria][:id]
        publicacao.conteudo_html = AGENTE.get(publicacao.url).parser.css('.post').to_s.force_encoding('iso-8859-1').encode('utf-8')
        Nokogiri::HTML(publicacao.conteudo_html).css('.alt2').to_s.scan(/[a-z]{3,5}:\/\/[^\s"<\\']*/).each do |link|
          l = Link.new
          l.link = link
          if Host.where(url: /[a-z]{3,5}:\/\/[a-zA-Z0-9.]+/.match(link).to_s).exists?
            host = Host.where(url: /[a-z]{3,5}:\/\/[a-zA-Z0-9.]+/.match(link).to_s)
            l.host_id = host.id
          else
            agent = Mechanize.new
            host = Host.new
            host.url = /[a-z]{3,5}:\/\/[a-zA-Z0-9.]+/.match(link).to_s
            pagina = agent.get(host.url)
            host.imagem_padrao = pagina.images[1]
            host.titulo = pagina.title.to_s
            host.ativo = false
            host.save
            l.host_id = Host.last.id
          end
          publicacao.links << l
        end
        if publicacao.save
          puts 'Publicação salva '+publicacao.titulo
        end
      end
    end
  end


end