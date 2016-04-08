require 'uri'
require 'rest_client'
require 'rexml/document'
require 'json'
require 'rubygems'
require 'mechanize'


unless MAX_PAGINAS_INDICE # Para evitar warning de variável já iniciada
  MAX_PAGINAS_INDICE = 20
end

namespace :importacao do


  @links=[]

  task :testes => :environment do

    tehparadox = Teh_Paradox.new
    puts "logado" if tehparadox.logar()
    tehparadox.processar_todas()

  end


end
