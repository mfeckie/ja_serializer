defmodule <%= inspect context.web_module %>.<%= inspect schema.alias %>Controller do
  use <%= inspect context.web_module %>, :controller

  alias <%= inspect context.module %>
  alias <%= inspect schema.module %>
  alias JaSerializer.Params

  action_fallback <%= inspect context.web_module %>.FallbackController

  def index(conn, _params) do
    <%= schema.plural %> = <%= inspect context.alias %>.list_<%= schema.plural %>()
    render(conn, "index.json-api", data: <%= schema.plural %>)
  end

  def create(conn, %{"data" => data = %{"type" => <%= inspect schema.singular%>, "attributes" => _<%= schema.singular%>_params}}) do
    with {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} <- <%= inspect context.alias %>.create_<%= schema.singular %>(Params.to_attributes(data)) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", <%= schema.singular %>_path(conn, :show, <%= schema.singular %>))
      |> render("show.json-api", data: <%= schema.singular %>)
    end
  end

  def show(conn, %{"id" => id}) do
    <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>!(id)
    render(conn, "show.json-api", data: <%= schema.singular %>)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => <%= schema.singular %>, "attributes" => _<%= schema.singular%>_params}}) do
    <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>!(id)

    with {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} <- <%= inspect context.alias %>.update_<%= schema.singular %>(<%= schema.singular %>, Params.to_attributes(data)) do
      render(conn, "show.json-api", data: <%= schema.singular %>)
    end
  end

  def delete(conn, %{"id" => id}) do
    <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>!(id)
    with {:ok, %<%= inspect schema.alias %>{}} <- <%= inspect context.alias %>.delete_<%= schema.singular %>(<%= schema.singular %>) do
      send_resp(conn, :no_content, "")
    end
  end
end