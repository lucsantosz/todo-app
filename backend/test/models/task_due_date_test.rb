require "test_helper"

class TaskDueDateTest < ActiveSupport::TestCase
  def build(due_date)
    Task.new(title: "Teste", category: categories(:work), due_date: due_date)
  end

  test "allows a blank due date" do
    assert build(nil).valid?
    assert build("").valid?
  end

  test "allows a real date" do
    assert build("2026-11-20").valid?
  end

  test "rejects a date that does not exist" do
    assert_not build("2026-13-45").valid?
  end

  test "rejects years outside the allowed range" do
    assert_not build("0021-11-21").valid?
    assert_not build("2500-01-01").valid?
  end
end
