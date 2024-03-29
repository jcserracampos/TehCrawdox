class WelcomeController < ApplicationController
  def index

    if Publicacao.count > 4
      @publicacoes = Publicacao.includes(:imagens).includes(links: :host).find(Publicacao.last.id,
                                     Publicacao.last.id-1,
                                     Publicacao.last.id-2,
                                     Publicacao.last.id-3)
    elsif Publicacao.count > 0
        @publicacoes = Publicacao.includes(:imagens).includes(links: :host).all
    else
      @publicacoes = []
    end

    @categorias = Categoria.all

    render 'welcome/index'
  end
end
