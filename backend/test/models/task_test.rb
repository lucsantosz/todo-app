require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "is valid with a title and a category" do
    assert Task.new(title: "Nova tarefa", category: categories(:work)).valid?
  end

  test "requires a title" do
    assert_not Task.new(title: "", category: categories(:work)).valid?
  end

  test "requires a category" do
    assert_not Task.new(title: "Sem categoria").valid?
  end

  test "has default status and priority" do
    task = Task.new

    assert_equal "pending", task.status
    assert_equal "medium", task.priority
  end

  test "rejects an invalid status" do
    task = Task.new(title: "Teste", category: categories(:work), status: "invalid")

    assert_not task.valid?
  end
end
