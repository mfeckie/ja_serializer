defmodule <%= inspect context.web_module %>.<%= inspect schema.alias %>View do
  use <%= inspect context.web_module %>, :view
  use JaSerializer.PhoenixView

  alias <%= inspect context.web_module %>.<%= inspect schema.alias %>View


  attributes [<%= Map.keys(schema.types) |> Enum.map(&(":#{&1}")) |> Enum.join(", ") %>]

  <%= for {ref, ref_id, _, _} <- schema.assocs do %>
  has_one :<%= ref %>,
    field: :<%= ref_id%>,
    type: "<%= ref %>"<% end %>

end
