require 'test_helper'

class TanetsControllerTest < ActionController::TestCase
  setup do
    @tanet = tanets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tanets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tanet" do
    assert_difference('Tanet.count') do
      post :create, tanet: { data: @tanet.data }
    end

    assert_redirected_to tanet_path(assigns(:tanet))
  end

  test "should show tanet" do
    get :show, id: @tanet
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tanet
    assert_response :success
  end

  test "should update tanet" do
    patch :update, id: @tanet, tanet: { data: @tanet.data }
    assert_redirected_to tanet_path(assigns(:tanet))
  end

  test "should destroy tanet" do
    assert_difference('Tanet.count', -1) do
      delete :destroy, id: @tanet
    end

    assert_redirected_to tanets_path
  end
end
