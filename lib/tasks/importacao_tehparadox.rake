require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'colorize'

AGENTE = Mechanize.new do |a|
  a.follow_meta_refresh = true
  a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Para evitar problemar com SSL
  # Mechanize deixa as conexões abertas e confia com coletor de lixo para limpá-las
  # Depois de um certo ponto, existem tantas conexões abertas que nenhuma conexão de saída pode ser estabelecida
  # Fazer: Fechar as conexões depois de usá-las
end


namespace :tehparadox do

  desc 'Procura todas as publicações em categorias ativas do TehParadox'
  task capturar_publicacoes: :environment do
    beginning_time = Time.now
    logar_tehparadox
    buscar_publicacoes
    processar_publicacao
    ending_time = Time.now
    puts ending_time - beginning_time
  end

  desc 'Procura todas as categorias do TehParadox'
  task capturar_categorias: :environment do
    logar_tehparadox
    buscar_categorias
  end

  def logar_tehparadox
    puts 'Logando'
    begin
      pagina = AGENTE.get('http://www.tehparadox.com')
    rescue Mechanize::ResponseCodeError
      puts 'Site indisponível /nTarefa cancelada'.red
      exit!
    else
      formulario = pagina.form
      # TODO: Criar um usuário para não utilizar o meu /JC
      # Preenche o formulário de login
      formulario.vb_login_username = 'USUARIO'
      formulario.vb_login_password = 'SENHA'
      # Submete o formulário de login
      pagina = AGENTE.submit(formulario, formulario.buttons.first)
      # Se o follow_meta não funcionar, redireciono para a página inicial de novo manualmente
      pagina = AGENTE.get('http://www.tehparadox.com')
      puts 'Usuário logado'.green
    end
  end

  def buscar_categorias
    regex = Regexp.new('(http:\/\/tehparadox.com\/forum\/f[0-9]{1,2})')
    # Acessa a página que contém todas as categorias
    categorias_pagina = AGENTE.get('http://www.tehparadox.com/forum')
    categorias = []
    # Percorre todos os links do fórum atrás de categorias
    categorias_pagina.links.each do |link|
      categorias << regex.match(link.uri.to_s).to_s if regex.match(link.uri.to_s)
    end

    categorias.each do |categoria_auxiliar|
      categoria_pagina = AGENTE.get(categoria_auxiliar)
      categoria = Categoria.new
      categoria.nome = categoria_pagina.title
      puts 'Categoria localizada '+categoria.nome

      # TODO Capturar a descrição.
      categoria.ativo = false
      categoria.url = categoria_pagina.uri.to_s
      categoria.site_id = Site.where(nome: 'TehParadox').first.id
      # FAZER capturar o nome até o hífen
      categoria.path = /\w+/.match(categoria.nome).to_s

      unless Categoria.where(nome: categoria.nome).exists?
        puts 'Categoria adicionada '+categoria.nome.green
        categoria.save
      end
    end
  end

  def buscar_publicacoes
    last_encontrados = 0
    # Buscar apenas nas categorias consideradas ativas
    categorias = Categoria.where(site_id: 2, ativo: true)

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
      unless Publicacao.where(titulo: pub[:texto]).exists?
        publicacao = Publicacao.new
        publicacao.titulo= pub[:texto].force_encoding('iso-8859-1').encode('utf-8')
        puts 'Publicação capturada '+publicacao.titulo
        unless publicacao.titulo === 'Ebook 101-How to\'s and tips'
          publicacao.codigo = pub[:atributos][:id]
          publicacao.url = pub[:href]
          # Captura o HTML da publicação
          publicacao.conteudo_html = AGENTE.get(publicacao.url).parser.css('.post').to_s.force_encoding('iso-8859-1').encode('utf-8')
          publicacao.conteudo = publicacao.conteudo_html.gsub(/<[^>]+>/, '')
          publicacao.descricao = publicacao.conteudo.slice(0...publicacao.conteudo.index('Code'))
          publicacao.situacao = '1'
          publicacao.exportado = false
          # Varre todos os links de uma tag img com a class padrão do TehParadox
          Nokogiri::HTML(publicacao.conteudo_html).css('.tcattdimgresizer').to_s.scan(/[a-z]{3,5}:\/\/[^\s"<\\']*/).each do |imagem|
            img = Imagem.new
            img.url = imagem
            publicacao.imagens << img
          end
          publicacao.categoria_id = pub[:categoria][:id]
          # Varre todos os links dentro de um campo code (.alt2)
          Nokogiri::HTML(publicacao.conteudo_html).css('.alt2').to_s.scan(/[a-z]{3,5}:\/\/[^\s"<\\']*/).each do |link|
            l = Link.new
            l.link = link
            if Host.where(url: /[a-z]{3,5}:\/\/[a-zA-Z0-9.]+/.match(link).to_s).exists?
              host = Host.where(url: /[a-z]{3,5}:\/\/[a-zA-Z0-9.]+/.match(link).to_s).first
              l.host_id = host.id
            else
              agent = Mechanize.new
              host = Host.new
              host.url = /[a-z]{3,5}:\/\/[a-zA-Z0-9.]+/.match(link).to_s
              begin
                pagina = agent.get(host.url)
              rescue Mechanize::ResponseCodeError
                puts 'Host indisponível!!!'.red
              rescue SocketError
                puts 'Host indisponível!!!'.red
              else
                host.imagem_padrao = pagina.images[0]
                host.titulo = pagina.title.to_s
                host.ativo = false
                host.save
                l.host_id = Host.last.id
              end
            end
            publicacao.links << l
          end
          if publicacao.save
            puts 'Publicação salva '+publicacao.titulo.green
          end
        end
      end
    end
  end
end
