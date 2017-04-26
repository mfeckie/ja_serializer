if Code.ensure_loaded?(Phoenix) do
  defmodule Mix.Tasks.Phx.Gen.JsonApi do
    use Mix.Task
    alias Mix.Phoenix.Context
    alias Mix.Tasks.Phx.Gen

    @shortdoc "Generates a JSON API based resource for Phoenix ~> 1.3"

    @moduledoc """
    Generates a Phoenix resource.

    mix ja_serializer.gen.phoenix_api Accounts User users name:string age:integer

    The first argument is the context module followed by the schema module and its plural name (used as the schema table name)

    The generated resource will contain:

    * a context module in `accounts/accounts.ex`, serving as the API boundary
    * a schema in `accounts/user.ex`, with an `accounts_users` table
    * a view in `web/views/user_view.ex`
    * a controller in `web/controllers/user_controller.ex`
    * a migration file for the repository
    * test files for generated model and controller

    """

    def run(args) do
      if Mix.Project.umbrella? do
        Mix.raise "mix phx.gen.json can only be run inside an application directory"
      end

      {context, schema} = Gen.Context.build(args)
      friendly_create_params = for_friendly_attributes(schema.params.create)
      friendly_update_params = for_friendly_attributes(schema.params.update)

      binding = [
        context: context,
        schema: schema,
        friendly_create_params: friendly_create_params,
        friendly_update_params: friendly_update_params
      ]

      context
      |> copy_new_files(paths(), binding)
      |> print_shell_instructions()
    end

    def copy_new_files(%Context{schema: schema} = context, paths, binding) do
      web_prefix = Mix.Phoenix.web_prefix()
      test_prefix = Mix.Phoenix.test_prefix()

      Mix.Phoenix.copy_from(paths, "priv/templates/phx_gen_json_api", "", binding, [
            {:eex,     "controller.ex",          Path.join(web_prefix, "controllers/#{schema.singular}_controller.ex")},
            {:eex,     "view.ex",                Path.join(web_prefix, "views/#{schema.singular}_view.ex")},
            {:eex,     "controller_test.exs",    Path.join(test_prefix, "controllers/#{schema.singular}_controller_test.exs")},
            {:new_eex, "changeset_view.ex",      Path.join(web_prefix, "views/changeset_view.ex")},
            {:new_eex, "fallback_controller.ex", Path.join(web_prefix, "controllers/fallback_controller.ex")},
          ])

      Gen.Context.copy_new_files(context, paths, binding)
      context
    end

    def print_shell_instructions(%Context{schema: schema} = context) do
      Mix.shell.info """
      Add the resource to your api scope in lib/#{Mix.Phoenix.otp_app()}/web/router.ex:
      resources "/#{schema.plural}", #{inspect schema.alias}Controller, except: [:new, :edit]
      """
      Gen.Context.print_shell_instructions(context)
    end

    defp paths do
      [
        ".",
        Mix.Project.deps_path |> Path.join("..") |> Path.expand,
        :ja_serializer,
        :phoenix
      ]
    end

    defp for_friendly_attributes(params) do
      params
      |> Enum.reverse
      |> Enum.with_index
      |> Enum.map(&to_template_string/1)
      |> Enum.reverse
    end

    defp to_template_string({{_, _} = map, index}) when index != 0, do: "#{to_template_string(map)},"
    defp to_template_string({{_, _} = map, _index}), do: to_template_string(map)
    defp to_template_string({key, value}) do
      kebab = to_kebab_attrs(key)
      ~s("#{kebab}" => #{to_value(value)})
    end


    defp to_kebab_attrs(key), do: String.replace("#{key}", "_", "-")
    defp to_value(%Date{} = date), do: ~s("#{date}")
    defp to_value(%NaiveDateTime{} = datetime), do: ~s("#{NaiveDateTime.to_iso8601(datetime)}")
    defp to_value(any), do: inspect(any)
  end
end
