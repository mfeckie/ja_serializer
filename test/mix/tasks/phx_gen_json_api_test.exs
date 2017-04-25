defmodule Mix.Tasks.JaSerializer.Gen.Phoenix.ApiTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Phx.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  test "invalid mix arguments", config do
    in_tmp_project config.test, fn ->
      assert_raise Mix.Error, ~r/Expected the context, "blog", to be a valid module name/, fn ->
        Gen.JsonApi.run(~w(blog Post posts title:string))
      end

      assert_raise Mix.Error, ~r/Expected the schema, "posts", to be a valid module name/, fn ->
        Gen.JsonApi.run(~w(Post posts title:string))
      end

      assert_raise Mix.Error, ~r/The context and schema should have different names/, fn ->
        Gen.JsonApi.run(~w(Blog Blog blogs))
      end

      assert_raise Mix.Error, ~r/Invalid arguments/, fn ->
        Gen.JsonApi.run(~w(Blog.Post posts))
      end

      assert_raise Mix.Error, ~r/Invalid arguments/, fn ->
        Gen.JsonApi.run(~w(Blog Post))
      end
    end
  end

   test "generates json resource", config do
    in_tmp_project config.test, fn ->
      Gen.JsonApi.run(["Blog", "Post", "posts", "title:string"])

      assert_file "lib/ja_serializer/blog/post.ex"
      assert_file "lib/ja_serializer/blog/blog.ex"

      assert_file "test/blog_test.exs", fn file ->
        assert file =~ "use JaSerializer.DataCase"
      end

      assert_file "test/web/controllers/post_controller_test.exs", fn file ->
        assert file =~ "defmodule JaSerializer.Web.PostControllerTest"
      end

      assert [_] = Path.wildcard("priv/repo/migrations/*_create_blog_post.exs")

      assert_file "lib/ja_serializer/web/controllers/fallback_controller.ex", fn file ->
        assert file =~ "defmodule JaSerializer.Web.FallbackController"
      end

      assert_file "lib/ja_serializer/web/controllers/post_controller.ex", fn file ->
        assert file =~ "defmodule JaSerializer.Web.PostController"
        assert file =~ "use JaSerializer.Web, :controller"
        assert file =~ "Blog.get_post!"
        assert file =~ "Blog.list_posts"
        assert file =~ "Blog.create_post"
        assert file =~ "Blog.update_post"
        assert file =~ "Blog.delete_post"
      end

      assert_file "lib/ja_serializer/web/views/changeset_view.ex", fn file ->
      end


      assert_file "lib/ja_serializer/web/views/post_view.ex", fn file ->
        assert file =~ "attributes [:title]"
      end

    end
  end
end
