require "test_helper"

class Admin::AdvertisementsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_advertisements_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_advertisements_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_advertisements_edit_url
    assert_response :success
  end

  test "should get create" do
    get admin_advertisements_create_url
    assert_response :success
  end

  test "should get update" do
    get admin_advertisements_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_advertisements_destroy_url
    assert_response :success
  end
end
