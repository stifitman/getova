require 'test_helper'

class ComplusControllerTest < ActionController::TestCase
  setup do
    @complu = complus(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:complus)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create complu" do
    assert_difference('Complu.count') do
      post :create, complu: { data: @complu.data }
    end

    assert_redirected_to complu_path(assigns(:complu))
  end

  test "should show complu" do
    get :show, id: @complu
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @complu
    assert_response :success
  end

  test "should update complu" do
    patch :update, id: @complu, complu: { data: @complu.data }
    assert_redirected_to complu_path(assigns(:complu))
  end

  test "should destroy complu" do
    assert_difference('Complu.count', -1) do
      delete :destroy, id: @complu
    end

    assert_redirected_to complus_path
  end
end
