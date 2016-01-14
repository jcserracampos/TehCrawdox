require 'uri'
require 'rest_client'
require "rexml/document"
require 'json'


MAX_PAGINAS_INDICE = 1

namespace :importacao do

  @user_id = '783a3533-7bd8-4c38-9d8f-e9c75d99894d'
  @api_key = '783a35337bd84c389d8fe9c75d99894d6932385ee7274630f681ad85428953fbe3c375c288c395051a4f888ea764590330ecb10f15a3c2097060c5e08d444f524413a61e1cf6b5dec6f974a26d20e29b'
  @id_api_listagem = "6bc6401e-6a79-43ba-aa27-d545d91cf02e"
  @id_api_detalhes = "50b2c084-0823-4e5a-bc2d-0c08c0bbe80c"

  @parametros = {
      :username => "adrianocortes",
      :password => "@alego123"
  }
  @cook = ''

  @pagina_base = 'http://tehparadox.com/forum/f58/'

  @links=[]

  task :importio => :environment do


    @categoria = Categoria.find_by_nome( "eBooks")


    if logar_forum( @pagina_base )
      ## Buscando pagina inicial
      puts "Buscando Pagina 01"
      buscar_links(@pagina_base)
      puts "Registrando #{("%04d" % @links.size)} Itens"
      registra_items_bd(@links)
      @links = []

      (2..MAX_PAGINAS_INDICE).each do |numero|
        puts "Buscando Pagina #{("%02d" % numero)}"
        buscar_links("#{@pagina_base}index#{numero}.html")
        puts "Registrando #{("%04d" % @links.size)} Itens"
        registra_items_bd(@links)
        @links = []

      end


      items_pendentes = Publicacao.where( situacao: Publicacao::CRIADA )
      qtd = 0
      items_pendentes.each do |publicacao|
        busca_destalhes( publicacao )
        qtd += 1

        puts "Items: #{qtd}" if qtd % 10 == 0
      end


      puts "##########################################"
      puts "Importação de Lista realizado com Sucesso"

    end
  end


  def logar_forum( pagina )

    puts "Logando"
    ##Chamando query para logar no site destino
    response = RestClient.post( "https://api.import.io/store/connector/#{@id_api_listagem}/_login?input/webpage/url=#{pagina}&_user=#{@user_id}&_apikey=#{@api_key}", @parametros.to_json, :content_type => :json, :accept => :json )

    unless response.code
      puts "Erro ao logar no Site"
      return false
    end

    jsao = JSON.parse( response.body )

    @cook = {"cookies":jsao["cookies"]}

    return true

  end

  def buscar_links( pagina )
    ##Funcao que busca uma pagina com os links dos posts
    ## Parametro: pagina - Se nil, busca pagina inicial do forum


    post = @cook
    post["input"] = {"webpage/url" => "#{pagina}"}
    caminho_completo = "https://api.import.io/store/connector/#{@id_api_listagem}/_query?&_user=#{@user_id}&_apikey=#{@api_key}"
    response = RestClient.post( caminho_completo, post.to_json, {:content_type => :json, :accept => :json } )


    items = JSON.parse( response.body )
    items = items["results"]


    items.each{|item| @links << item}

    registra_items_bd( @links )
    @links = []
  end

  def busca_destalhes( publicacao )

    contador = 0
    resultado = false

    while resultado == false and contador < 2
      begin
        logar_forum( @pagina_base ) if @cook.nil?
        post = @cook
        post["input"] = {"webpage/url" => "#{publicacao.url}"}
        caminho_completo = "https://api.import.io/store/connector/#{@id_api_detalhes}/_query?&_user=#{@user_id}&_apikey=#{@api_key}"
        response = RestClient.post( caminho_completo, post.to_json, {:content_type => :json, :accept => :json } )

        items_json = JSON.parse( response.body )
        items = items_json["results"]
        if items[0].size != 3
          raise 'Resultado vazio'
        end



        publicacao.link_imagem = items[0]["image_post"] unless items[0]["image_post"].size > 1
        publicacao.titulo = items[0]["title_post"]
        publicacao.descricao = items[0]["conteudo_post"]
        publicacao.situacao = Publicacao::NOVA
        publicacao.categoria = @categoria

        if publicacao.save
          unless publicacao.link_imagem.nil?
            publicacao.caminho_imagem = "#{@categoria.pasta_imagens}/#{ "%09d" % publicacao.id }#{File.extname(publicacao.link_imagem)}"
            IO.copy_stream(open( publicacao.link_imagem ), publicacao.caminho_imagem )
            publicacao.save
          end
        end



        resultado = true
      rescue Exception => e
        contador += 1
        resultado = false
        @cook = nil
        puts "************************************ #{( "%04d" % contador)}"
        puts "Erro: #{e.message}"
      end
    end

  end


  def registra_items_bd( links )

    links.each do |link|

      codigo = 0
      url_texto = ""

      if link['link_post'].class == Array
        url_texto = link['link_post'][0]
      else
        url_texto = link['link_post']
      end


      if url_texto.split('/').last.split("-").last == 'new'
        codigo = url_texto.split('/').last.split("-").last.to_i
      else
        codigo = url_texto.split('/').last.split("-")[-1]
      end

      publicacoes = Publicacao.where( codigo: codigo )
      if publicacoes.size == 0
        publicacao = Publicacao.new
        publicacao.titulo = link['title_post']
        publicacao.url = url_texto
        publicacao.codigo = codigo
        publicacao.situacao = Publicacao::CRIADA
        publicacao.save
      end
    end


  end


end