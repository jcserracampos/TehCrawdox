class WelcomeController < ApplicationController
  def index
    @publicacoes = Publicacao.find(Publicacao.last.id,Publicacao.last.id-1,Publicacao.last.id-2,Publicacao.last.id-3)
    @categorias = Categoria.all


    render 'welcome/index'
  end
end
