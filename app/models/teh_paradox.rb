require 'mechanize'
require 'json'


class Teh_Paradox


  DEBUG_ERROR = 0
  DEBUG_WARN = 1
  DEBUG_INFO = 3
  DEBUG_ALL = 10

  DEBUG_LEVEL = DEBUG_ALL

  LIMITE_ERROS_DATA_ANTIGA = 3
  LIMITE_ERROS_DUPLICADOS = 3

  attr_internal_accessor :categorias


  USUARIO = 'adrianocortes'
  SENHA = '@alego123'


  PAGINA_INICIAL = 'http://www.tehparadox.com'
  FORM_LOGIN_PAGE = 'http://tehparadox.com/forum/login.php?do=login'

  DATA_LIMITE = DateTime.now - 2.week


  def initialize

    self.categorias = []
    self.categorias << {:nome => 'eBooks', :link => '/forum/f58'}

    @@crawler = Mechanize.new { |agent|
      # Flickr refreshes after login
      agent.follow_meta_refresh = true
    }
    @@pagina = @@crawler.get(PAGINA_INICIAL)

    @@links = []
    @@posts  = []

  end


  def logar

      ##Recarrega a pagina inicial ( o login está em todas as paginas, mas vamos usar a inicial )
      @@pagina = @@crawler.get(PAGINA_INICIAL)
      unless valida_pagina( @@pagina )
        return nil
      end

      # preenche e aciona o formulario de logim
      my_page = @@pagina.form_with(:action => "#{FORM_LOGIN_PAGE}" ) do |f|
        f.vb_login_username  = USUARIO
        f.vb_login_password  = SENHA
      end.click_button

      @@pagina = @@crawler.click(my_page.link_with(:text => /Click here if your browser does not automatically redirect you./))
      unless valida_pagina( @@pagina )
        return nil
      end
      return @@pagina


  end




  def processar_todas
    self.categorias.each do |categoria|
      self.registra_log( "Processando Categoria #{categoria[:nome]}", DEBUG_INFO )
      self.processar_categoria( categoria[:nome])
    end
  end

  def processar_categoria( categoria_name )
    categoria = self.localiza_categoria( categoria_name )
    unless categoria
      self.registra_log( "Categoria '#{categoria_name}' não encontrada!", DEBUG_WARN )
      return false
    end


    ##Carrega primeira pagina da Categoria, ordenado pela data de postagem
    pagina_categoria = @@crawler.get( "#{PAGINA_INICIAL}#{categoria[:link]}?sort=dateline&order=desc&daysprune=-1")
    unless valida_pagina( pagina_categoria )
      return false
    end

    indice = 0

    while true
      unless buscar_links_direto( pagina_categoria, categoria )
        self.registra_log( "Erro ao buscar links para Categoria '#{categoria_name}'!", DEBUG_WARN )
        return false
      end

      resultado_processamento = busca_detalhes( @@links )


      indice += 1
      if indice > 10
        break
      end
      pagina_categoria = busca_proxima_pagina( pagina_categoria )
      unless valida_pagina( pagina_categoria )
        return false
      end
      break unless pagina_categoria
    end




  end

  def buscar_links_direto( pagina_categoria, categoria )



    last_encontrados = 0
    ##Varre todos os links da pagina
    pagina_categoria.links.each do |link|
      text = link.text.strip
      href = link.href
      atributos = link.attributes

      next unless text.length > 0 ## Ignora imagens ( texto vem vazio)
      next unless href.include?( categoria[:link] ) ## Ignora aqueles que não são links para a propria categoria
      next if  href[-4,4] == "new/" ## Ignora links para "Primeiro post não lido", caso contrario fica repedito
      next if text.to_i > 0 ## Pula paginacao numeros
      if text == 'Last Page'
        if last_encontrados > 0
          break
        end
        last_encontrados += 1
        next
      end
      next if ['Last', '<', '>', 'Forum Tools', 'Forum Tools', 'Forum Tools', 'Thread', 'Thread Starter', 'Last »', '« First', 'Last Post',  'Reverse Sort Order', 'Replies',
               'Search this Forum', 'Rating', 'Views', 'Open Contacts Popup', 'Top', 'Mark This Forum Read' ].include?( text )
      #return true if href.include?( "#{categoria[:link]}/index" ) and  ## Ignora links para paginas da categoria


      registra_log( "Capturado Link para '#{text}'", DEBUG_INFO )
      @@links << {:texto => text, :href => href, :atributos => atributos,:categoria => categoria }

    end



  end


  def registra_log( mensagem, level = DEBUG_WARN )
    puts mensagem if level <= DEBUG_LEVEL
  end



  def localiza_categoria( nome_categoria)
    self.categorias.each do |categoria|
      return categoria if categoria[:nome] == nome_categoria
    end
  end



  def busca_proxima_pagina( pagina )
    return @@crawler.click( pagina.link_with(:text => />/))
  end


  def busca_detalhes( links )
    erros_existente = 0
    erros_data = 0


    links.each do |link|
      post_id = link[:href].split('-').last.to_i
      if @@posts.include?(post_id)
        erros_existente += 1
        self.registra_log( "Post '#{link[:texto]}' Duplicado", DEBUG_WARN )
        break if erros_existente >= LIMITE_ERROS_DUPLICADOS
        next
      end
      detalhe = @@crawler.get( link[:href])
      data = busca_data( detalhe )
      unless DATA_LIMITE.nil?
        if data < DATA_LIMITE
          erros_data += 1
          registra_log( 'Anterior a Data Limite', DEBUG_INFO )
          break if erros_data >= LIMITE_ERROS_DATA_ANTIGA
          next
        end
      end


      @@posts << post_id
      self.registra_log( "Post '#{link[:texto]}' INCLUIDO")

    end

    return erros_existente, erros_data
  end





  def valida_pagina( pagina )
    if pagina.nil? or pagina.blank?
      registra_log( "Pagina Nula/Vazia", DEBUG_ERROR )
      return false
    end

    if pagina.body.include?( 'The server is too busy at the moment. Please try again later.' )
      registra_log( "Servidor Ocupado!", DEBUG_WARN )
      return false
    end


    return true
  end


  def busca_data( pagina_detalhe )

    dados_td = pagina_detalhe.search "/html/body/div[2]/div[3]/div[2]/div[1]/div[1]/table/tr[1]/td[1]"
    data_str = ''
    dados_td.each do |item|
      data_str = item.text.strip
    end
    data = nil


    if data_str.include?('Ago')

      ## Até 4 semanas, vem como X [hour, day, week] Ago
      if data_str.include?( 'Minute' )
        data = DateTime.now - data_str.split(' ')[0].to_i.minute

      elsif data_str.include?( 'Hour' )
        data = DateTime.now - data_str.split(' ')[0].to_i.hour
      elsif data_str.include?( 'Day' )
        data = DateTime.now - data_str.split(' ')[0].to_i.day
      elsif data_str.include?( 'Week')
        data = DateTime.now - data_str.split(' ')[0].to_i.week
      elsif data_str.include?( 'Month')
        data = DateTime.now - data_str.split(' ')[0].to_i.month
      end
    else
      ##Acima de 4 semanas vem como data
      data = DateTime.strptime(data_str, '%m-%d-%y, %H:%M %p')
    end
    return data

  end


end
