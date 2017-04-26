defmodule <%= inspect context.web_module %>.ChangesetView do
  use <%= inspect context.web_module %>, :view

  def render("error.json-api", %{changeset: changeset}) do
    changeset
    |> JaSerializer.EctoErrorSerializer.format
  end
end
