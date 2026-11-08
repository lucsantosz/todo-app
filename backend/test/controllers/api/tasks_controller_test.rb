require "test_helper"

class Api::TasksControllerTest < ActionDispatch::IntegrationTest
  test "index lists tasks with their category" do
    get api_tasks_url, as: :json

    assert_response :success
    assert_equal Task.count, response.parsed_body.size
    assert response.parsed_body.first["category"]["name"].present?
  end

  test "index filters by category" do
    get api_tasks_url(category_id: categories(:work).id)

    assert_response :success
    assert_equal [ "Escrever relatório" ], JSON.parse(response.body).map { |task| task["title"] }
  end

  test "index filters by status" do
    get api_tasks_url(status: "in_progress")

    assert_response :success
    assert_equal [ "Estudar Rails" ], JSON.parse(response.body).map { |task| task["title"] }
  end

  test "index filters by priority" do
    get api_tasks_url(priority: "high")

    assert_response :success
    assert_equal [ "Escrever relatório" ], JSON.parse(response.body).map { |task| task["title"] }
  end

  test "create adds a task" do
    assert_difference "Task.count", 1 do
      post api_tasks_url,
           params: { task: { title: "Nova", priority: "low", category_id: categories(:work).id } },
           as: :json
    end

    assert_response :created
    assert_equal "pending", response.parsed_body["status"]
  end

  test "create rejects a blank title" do
    assert_no_difference "Task.count" do
      post api_tasks_url, params: { task: { title: "", category_id: categories(:work).id } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "update changes the status" do
    patch api_task_url(tasks(:write_report)), params: { task: { status: "done" } }, as: :json

    assert_response :success
    assert_equal "done", tasks(:write_report).reload.status
  end

  test "destroy removes the task" do
    assert_difference "Task.count", -1 do
      delete api_task_url(tasks(:write_report)), as: :json
    end

    assert_response :no_content
  end
end
