defmodule <%= inspect context.web_module %>.<%= inspect schema.alias %>ControllerTest do
  use <%= inspect context.web_module %>.ConnCase

  alias <%= inspect context.module %>
  alias <%= inspect schema.module %>

  @create_attrs <%= inspect schema.params.create %>
  @update_attrs <%= inspect schema.params.update %>
  @invalid_attrs <%= inspect for {key, _} <- schema.params.create, into: %{}, do: {key, nil} %>

  def fixture(:<%= schema.singular %>) do
    {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.create_<%= schema.singular %>(@create_attrs)
    <%= schema.singular %>
  end

  defp relationships do
    %{}
  end

  setup %{conn: conn} do
    conn = conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, <%= schema.singular %>_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates <%= schema.singular %> and renders <%= schema.singular %> when data is valid", %{conn: conn} do
    conn = post conn, <%= schema.singular %>_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "<%= schema.singular %>",
        "attributes" => @create_attrs,
        "relationships" => relationships()
      }
    }

    assert json_response(conn, 201)["data"]["attributes"] == %{
    <%= for param <- friendly_create_params do %>
      <%= param %><% end %>
    }
  end

  test "does not create <%= schema.singular %> and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, <%= schema.singular %>_path(conn, :create), %{
      "meta" => %{},
      "data" => %{
        "type" => "<%= schema.singular %>",
        "attributes" => @invalid_attrs,
        "relationships" => relationships()
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen <%= schema.singular %> and renders <%= schema.singular %> when data is valid", %{conn: conn} do
    %<%= inspect schema.alias %>{id: id} = <%= schema.singular %> = fixture(:<%= schema.singular %>)
    conn = put conn, <%= schema.singular %>_path(conn, :update, <%= schema.singular %>), %{
      "meta" => %{},
      "data" => %{
        "type" => "<%= schema.singular %>",
        "id" => <%= schema.singular %>.id,
        "attributes" => @update_attrs,
        "relationships" => relationships()
      }
    }

    assert json_response(conn, 200) == %{
      "data" => %{
        "type" => "<%= schema.singular%>",
        "id" => "#{id}",
          "attributes" => %{<%= for param <- friendly_update_params do %>
            <%= param %><% end %>
          }
      },
      "jsonapi" => %{"version" => "1.0"}
    }
  end

  test "does not update chosen <%= schema.singular %> and renders errors when data is invalid", %{conn: conn} do
    <%= schema.singular %> = fixture(:<%= schema.singular %>)

    conn = put conn, <%= schema.singular %>_path(conn, :update, <%= schema.singular %>), %{
      "meta" => %{},
      "data" => %{
        "type" => "<%= schema.singular %>",
        "id" => <%= schema.singular %>.id,
        "attributes" => @invalid_attrs,
        "relationships" => relationships()
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen <%= schema.singular %>", %{conn: conn} do
    <%= schema.singular %> = fixture(:<%= schema.singular %>)
    conn = delete conn, <%= schema.singular %>_path(conn, :delete, <%= schema.singular %>)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, <%= schema.singular %>_path(conn, :show, <%= schema.singular %>)
    end
  end
end
