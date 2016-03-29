require 'uri'
require 'rest_client'
require 'rexml/document'
require 'json'
require 'rubygems'
require 'mechanize'



MAX_PAGINAS_INDICE = 20

namespace :importacao do



  @links=[]

  task :testes => :environment do

    tehparadox = Teh_Paradox.new
    puts "logado" if tehparadox.logar()
    tehparadox.processar_todas()

  end


end
