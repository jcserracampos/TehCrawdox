require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

namespace :mechanize do
  task avx_publicacoes: :environment do
    puts 'Processando'
    ebooks = AGENTE.get('http://avxhome.in/ebooks')
    links = []
    Nokogiri::HTML(open('http://avxhome.in/ebooks')).to_s.scan(/\/ebooks\/[a-zA-Z0-9]+\.html/).each do |link|
      link = 'http://avxhome.in'+link
      links << link
    end
    puts 'Adicionando '+links.length.to_s+' publicações'
    links.each do |publicacao|
      begin
        ebook = AGENTE.get(publicacao)
      rescue

      else
        noko = Nokogiri::HTML(open(publicacao))
        p = Publicacao.new
        p.titulo = ebook.title
        puts 'Processando '+p.titulo
        p.codigo = ''
        p.url = publicacao
        p.situacao = '1'
        i = p.imagens.new
        i.imagem = ebook.images[0].to_s
        p.exportado = false
        p.categoria = Categoria.where(nome: 'Avx Home').first
        p.conteudo_html = noko.css('.col-md-12.article').to_s
        p.conteudo_html.scan(/[a-z]{3,5}:\/\/[^\s"<\\']*/).each do |link|
          unless (/pxhst/).match(link) ||
              (/avxhome/).match(link) ||
              (/friendlyduckaffiliates/).match(link)
            l = p.links.new
            l.link = link
            l.host = Host.where(url: /[a-z]{3,5}:\/\/[a-zA-Z0-9.]+/.match(link).to_s).first
          end
        end
        if p.save
          puts p.titulo+' salva'
        end
      end


    end

  end
end