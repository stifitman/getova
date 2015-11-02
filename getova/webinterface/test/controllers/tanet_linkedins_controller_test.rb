require 'test_helper'

class TanetLinkedinsControllerTest < ActionController::TestCase
  setup do
    @tanet_linkedin = tanet_linkedins(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tanet_linkedins)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tanet_linkedin" do
    assert_difference('TanetLinkedin.count') do
      post :create, tanet_linkedin: { data: @tanet_linkedin.data, name: @tanet_linkedin.name }
    end

    assert_redirected_to tanet_linkedin_path(assigns(:tanet_linkedin))
  end

  test "should show tanet_linkedin" do
    get :show, id: @tanet_linkedin
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tanet_linkedin
    assert_response :success
  end

  test "should update tanet_linkedin" do
    patch :update, id: @tanet_linkedin, tanet_linkedin: { data: @tanet_linkedin.data, name: @tanet_linkedin.name }
    assert_redirected_to tanet_linkedin_path(assigns(:tanet_linkedin))
  end

  test "should destroy tanet_linkedin" do
    assert_difference('TanetLinkedin.count', -1) do
      delete :destroy, id: @tanet_linkedin
    end

    assert_redirected_to tanet_linkedins_path
  end
end
