defmodule Turing.Graphql.SchemaTest do

  use TuringWeb.ConnCase

  alias Turing.Accounts.{Credential, User}

  setup do
    {:ok, user} = Repo.insert(%User{first_name: "Jon Snow"})
    %Credential{}
    |> Credential.changeset(
      %{
        email: "john.snow@got.com",
        password: "d3vP455",
        user_id: user.id
      }
    )
    |> Repo.insert()

    {:ok, %{user: user}}
  end

  describe "sign_up" do

    test "creates an account with valid data", %{conn: conn} do
      response =
        graphql_query(
          conn,
          query: """
            mutation signup {
              signup(
                first_name: "John"
                credential: {
                  email: "john.snow@got.net"
                  password: "D3v3l0p3r#!"
                  password_confirmation: "D3v3l0p3r#!"
                }
              ) {
                id
                first_name
                last_name
                credential {
                  email
                }
                inserted_at
                updated_at
              }
            }
          """
      )

      assert %{
        "data" => %{
          "signup" => %{
            "credential" => %{
              "email" => email,
            },
            "first_name" => first_name,
            "id" => _id,
            "inserted_at" => _inserted_at,
            "last_name" => _last_name,
            "updated_at" => _updated_at
          }
        }
      } = response
      assert first_name == "John"
      assert email == "john.snow@got.net"
    end

    test "raises error when email already exists", %{conn: conn} do
      response =
        graphql_query(
          conn,
          query: """
            mutation signup {
              signup(
                first_name: "John"
                credential: {
                  email: "john.snow@got.com"
                  password: "D3v3l0p3r#!"
                  password_confirmation: "D3v3l0p3r#!"
                }
              ) {
                id
                first_name
                last_name
                credential {
                  email
                }
                inserted_at
                updated_at
              }
            }
          """
      )

      assert %{
        "data" => _data,
        "errors" => [
          %{
            "locations" => _locations,
            "message" => message,
            "path" => _path
          }
        ]
      } = response
      assert message == "email has already been taken"
    end

  end

  describe "update_user" do

    test "updates current user's account with valid data", %{conn: conn, user: user} do
      {:ok, jwt, _full_claims} = Turing.Auth.Guardian.encode_and_sign(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")

      response =
        graphql_query(
          conn,
          query: """
            mutation update_user {
              update_user(
                user: {
                  first_name: "Bruce",
                  last_name: "Wayne",
                  credential: {
                    email: "bruce@waynetech.com"
                  }
                }
              ) {
                id,
                first_name
                last_name
                credential {
                  email
                }
                inserted_at
                updated_at
              }
            }
          """
      )

      %{
        "data" => %{
          "update_user" => %{
            "credential" => %{
              "email" => email
            },
            "first_name" => first_name,
            "id" => _id,
            "inserted_at" => _inserted_at,
            "last_name" => last_name,
            "updated_at" => _updated_at
          }
        }
      } = response
      assert email == "bruce@waynetech.com"
      assert first_name == "Bruce"
      assert last_name == "Wayne"
    end

    test "raises error with invalid data", %{conn: conn, user: user} do
      {:ok, jwt, _full_claims} = Turing.Auth.Guardian.encode_and_sign(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")

      response =
        graphql_query(
          conn,
          query: """
            mutation update_user {
              update_user(
                user: {
                  first_name: "",
                  last_name: "",
                  credential: {
                    email: ""
                  }
                }
              ) {
                id,
                first_name
                last_name
                credential {
                  email
                }
                inserted_at
                updated_at
              }
            }
          """
      )

      %{
        "data" => _data,
        "errors" => [
          %{
            "locations" => _locations,
            "message" => message,
            "path" => _path
          }
        ]
      } = response
      assert message == "first_name can't be blank, email can't be blank"
    end

  end

  describe "sign_in" do

    test "creates a session with valid data", %{conn: conn} do
      response =
        graphql_query(
          conn,
          query: """
            mutation login {
              login(
                email: "john.snow@got.com"
                password: "d3vP455"
              ) {
                token
              }
            }
          """
      )

     assert %{
        "data" => %{
          "login" => %{
            "token" => _token
          }
        }
      } = response
    end

    test "raises error with invalid data", %{conn: conn} do
      response =
        graphql_query(
          conn,
          query: """
            mutation login {
              login(
                email: "john.snow@got.com"
                password: "d3vP45X"
              ) {
                token
              }
            }
          """
      )

     assert %{
        "data" => %{"login" => _login},
        "errors" => [
          %{
            "locations" => _locations,
            "message" => message,
            "path" => _path
          }
        ]
      } = response
      assert message == "Invalid credentials"
    end

  end

  describe "sign_out" do

    test "revokes user token", %{conn: conn, user: user} do
      {:ok, jwt, _full_claims} = Turing.Auth.Guardian.encode_and_sign(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")

      response =
        graphql_query(
          conn,
          query: """
            mutation logout {
              logout {
                message
              }
            }
          """
      )

      assert response == %{"data" => %{"logout" => %{"message" => "You have been logged out!"}}}
    end

  end
end