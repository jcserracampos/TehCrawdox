class WelcomeController < ApplicationController
  def index
    if Publicacao.last
      @publicacoes = Publicacao.find(Publicacao.last.id, Publicacao.last.id-1, Publicacao.last.id-2, Publicacao.last.id-3)

    else
      @publicacoes = []

    end
    @categorias = Categoria.all


    render 'welcome/index'
  end
end
