require "test_helper"

class Api::TasksDueDateTest < ActionDispatch::IntegrationTest
  test "create rejects an invalid due date" do
    assert_no_difference "Task.count" do
      post api_tasks_url,
           params: { task: { title: "Teste", due_date: "2026-13-45", category_id: categories(:work).id } },
           as: :json
    end

    assert_response :unprocessable_entity
  end
end
