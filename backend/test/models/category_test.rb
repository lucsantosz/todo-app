require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "is valid with a name" do
    assert Category.new(name: "Casa").valid?
  end

  test "requires a name" do
    assert_not Category.new(name: "").valid?
  end

  test "name must be unique ignoring case" do
    assert_not Category.new(name: "trabalho").valid?
  end

  test "destroying a category destroys its tasks" do
    category = categories(:work)

    assert_difference "Task.count", -category.tasks.count do
      category.destroy
    end
  end
end
