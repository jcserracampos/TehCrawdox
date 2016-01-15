require 'nokogiri'
require 'dlc'

namespace :importacao do
  task gerar_jdownloader: :environment do

    regex = /[a-z]{3,5}:\/\/[^\s\"\<\\\']*/

    publicacoes = Publicacao.where(situacao: Publicacao::CONFIRMADA)

    Dir.chdir('dlc')

    publicacoes.each do |publicacao|

      # Procurando os links na descrição da publicação
      descricao_publicacao = Nokogiri::HTML(publicacao.descricao)
      links = descricao_publicacao.css('.alt2').to_s # Traz o que tem dentro de um campo CODE (Geralmente os links)


     # Necessário varrer a variável para separar os links por host
      publicacao_links = links.match(publicacao.host)


      # Criando o pacote
      pacote = DLC::Package.new # Iniciando o pacote
      pacote.name = publicacao.titulo # Definindo o nome do pacote como o nome da publicacao
      pacote.add_link(links) # Adicionando os links ao pacote

      # Gravando o pacote
      open("#{pacote.name}.dlc", "w") do |f|
        f.write pacote.dlc
      end

    end


  end
end