require 'test_helper'

class PublicacoesControllerTest < ActionController::TestCase
  setup do
    @publicacao = publicacoes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:publicacoes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create publicacao" do
    assert_difference('Publicacao.count') do
      post :create, publicacao: { caminho_imagem: @publicacao.caminho_imagem, categoria_id: @publicacao.categoria_id, codigo: @publicacao.codigo, descricacao: @publicacao.descricacao, exportado: @publicacao.exportado, link_imagem: @publicacao.link_imagem, situacao: @publicacao.situacao, titulo: @publicacao.titulo, url: @publicacao.url }
    end

    assert_redirected_to publicacao_path(assigns(:publicacao))
  end

  test "should show publicacao" do
    get :show, id: @publicacao
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @publicacao
    assert_response :success
  end

  test "should update publicacao" do
    patch :update, id: @publicacao, publicacao: { caminho_imagem: @publicacao.caminho_imagem, categoria_id: @publicacao.categoria_id, codigo: @publicacao.codigo, descricacao: @publicacao.descricacao, exportado: @publicacao.exportado, link_imagem: @publicacao.link_imagem, situacao: @publicacao.situacao, titulo: @publicacao.titulo, url: @publicacao.url }
    assert_redirected_to publicacao_path(assigns(:publicacao))
  end

  test "should destroy publicacao" do
    assert_difference('Publicacao.count', -1) do
      delete :destroy, id: @publicacao
    end

    assert_redirected_to publicacoes_path
  end
end
