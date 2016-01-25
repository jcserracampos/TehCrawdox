class PublicacoesController < ApplicationController
  before_action :set_publicacao, only: [:show, :edit, :update, :destroy, :confirmar]

  # GET /publicacoes
  # GET /publicacoes.json
  def index
    @publicacoes = Publicacao.all
  end

  # GET /publicacoes/1
  # GET /publicacoes/1.json
  def show
  end

  # GET /publicacoes/new
  def new
    @publicacao = Publicacao.new
  end

  # GET /publicacoes/1/edit
  def edit
  end

  # POST /publicacoes
  # POST /publicacoes.json
  def create
    @publicacao = Publicacao.new(publicacao_params)

    respond_to do |format|
      if @publicacao.save
        format.html { redirect_to @publicacao, notice: 'Publicacao was successfully created.' }
        format.json { render :show, status: :created, location: @publicacao }
      else
        format.html { render :new }
        format.json { render json: @publicacao.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /publicacoes/1
  # PATCH/PUT /publicacoes/1.json
  def update
    respond_to do |format|
      if @publicacao.update(publicacao_params)
        format.html { redirect_to @publicacao, notice: 'Publicacao was successfully updated.' }
        format.json { render :show, status: :ok, location: @publicacao }
      else
        format.html { render :edit }
        format.json { render json: @publicacao.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /publicacoes/1
  # DELETE /publicacoes/1.json
  def destroy
    @publicacao.destroy
    respond_to do |format|
      format.html { redirect_to publicacoes_url, notice: 'Publicacao was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def analisar
    @publicacoes = Publicacao.where(situacao: 1).order("created_at").limit(10)

  end

  def confirmar
    @publicacao = Publicacao.find(params[:id])
    @publicacao.situacao = Publicacao::CONFIRMADA
    @publicacao.host = params[:host]
    @publicacao.save

    # redirect_to action: "index"
  end

  def confirmar_sem_host
    @publicacao.situacao = Publicacao::Confirmada

    # redirect_to action: "index"
  end

  def rejeitar
    @publicacao.situacao = Publicacao::REJEITADA
    @publicacao.save

    redirect_to action: "analisar"

  end

  def ignorar
    @publicacao.situacao = Publicacao::IGNORADA
    @publicacao.save

    redirect_to action: "analisar"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_publicacao
      @publicacao = Publicacao.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def publicacao_params
      params.require(:publicacao).permit(:titulo, :descricao, :codigo, :url, :link_imagem, :caminho_imagem, :situacao, :exportado, :categoria_id, :host)
    end
end
