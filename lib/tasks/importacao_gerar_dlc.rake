require 'nokogiri'
require 'dlc'

namespace :importacao do
  task gerar_jdownloader: :environment do
    publicacoes = Publicacao.where(situacao: Publicacao::CONFIRMADA)

    Dir.chdir('dlc')

    publicacoes.each do |publicacao|
      publicacao_links = []
      if publicacao.host_id.blank?
        publicacao.links.each do |l|
          publicacao_links << l.link
        end
      else
        # Necessário varrer a variável para separar os links por host
        publicacao.links.where(host: publicacao.host).all.each do |l|
          publicacao_links << l.link
        end
      end


      # Criando o pacote
      pacote = DLC::Package.new # Iniciando o pacote
      pacote.name = publicacao.titulo[0...20] # Definindo o nome do pacote como o nome da publicacao
      pacote.add_link(publicacao_links) # Adicionando os links ao pacote

      # Gravando o pacote
      File.open("#{pacote.name}.dlc", 'w+') do |f|
        f.write pacote.dlc
      end

    end


  end
end