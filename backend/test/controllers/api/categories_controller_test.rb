require "test_helper"

class Api::CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "index lists categories" do
    get api_categories_url, as: :json

    assert_response :success
    assert_equal Category.count, response.parsed_body.size
  end

  test "create adds a category" do
    assert_difference "Category.count", 1 do
      post api_categories_url, params: { category: { name: "Casa" } }, as: :json
    end

    assert_response :created
  end

  test "create rejects a blank name" do
    assert_no_difference "Category.count" do
      post api_categories_url, params: { category: { name: "" } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "update changes the name" do
    patch api_category_url(categories(:work)), params: { category: { name: "Escritório" } }, as: :json

    assert_response :success
    assert_equal "Escritório", categories(:work).reload.name
  end

  test "destroy removes the category" do
    assert_difference "Category.count", -1 do
      delete api_category_url(categories(:work)), as: :json
    end

    assert_response :no_content
  end
end
