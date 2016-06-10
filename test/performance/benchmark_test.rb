require 'test_helper'

class BenchmarkTest < ActionDispatch::IntegrationTest
  test "basic" do
    $readingTime = 5
    $writingTime = 2

    $readingTime.times do
      get "/"
    end
    assert_template "static_pages/home"

    $readingTime.times do
      get "/signup"
      post "/users", user: { name:  "", email: "user@invalid", password: "foo", password_confirmation: "bar" }
    end
    assert_template "users/new"

    $writingTime.times do
      username = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
      email = username + "@gmail.com"
      password = (0...10).map { ('a'..'z').to_a[rand(26)] }.join

      get "/signup"
      post_via_redirect "/users", user: { name: username, email: email, password: password, password_confirmation: password }
    end
    assert_template "users/show"

    $readingTime.times do
      get "/users/" + User.first.id.to_s
    end
    assert_template "users/show"
  end
end
