require 'test_helper'

class IndividualFormatsControllerTest < ActionController::TestCase
  setup do
    @individual_format = individual_formats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:individual_formats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create individual_format" do
    assert_difference('IndividualFormat.count') do
      post :create, individual_format: { baseToFormat: @individual_format.baseToFormat, formatToBase: @individual_format.formatToBase, name: @individual_format.name }
    end

    assert_redirected_to individual_format_path(assigns(:individual_format))
  end

  test "should show individual_format" do
    get :show, id: @individual_format
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @individual_format
    assert_response :success
  end

  test "should update individual_format" do
    patch :update, id: @individual_format, individual_format: { baseToFormat: @individual_format.baseToFormat, formatToBase: @individual_format.formatToBase, name: @individual_format.name }
    assert_redirected_to individual_format_path(assigns(:individual_format))
  end

  test "should destroy individual_format" do
    assert_difference('IndividualFormat.count', -1) do
      delete :destroy, id: @individual_format
    end

    assert_redirected_to individual_formats_path
  end
end
