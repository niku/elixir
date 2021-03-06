Code.require_file "../../test_helper.exs", __DIR__

defmodule Mix.Tasks.EscriptTest do
  use MixTest.Case

  defmodule Escript do
    def project do
      [ app: :escripttest,
        version: "0.0.1",
        escript: [
          main_module: Escripttest,
          name: "escriptest",
          embed_elixir: true
        ]
      ]
    end
  end

  defmodule EscriptWithPath do
    def project do
      [ app: :escripttestwithpath,
        version: "0.0.1",
        escript: [
          app: nil,
          embed_elixir: true,
          main_module: Escripttest,
          path: Path.join("ebin", "escripttestwithpath")
        ]
      ]
    end
  end

  defmodule EscriptWithDeps do
    def project do
      [ app: :escripttestwithdeps,
        version: "0.0.1",
        escript: [
          main_module: Escripttest,
          path: Path.join("ebin", "escripttestwithdeps"),
        ],
        deps: [{:ok, path: fixture_path("deps_status/deps/ok")}] ]
    end
  end

  test "generate simple escript" do
    Mix.Project.push Escript

    in_fixture "escripttest", fn ->
      Mix.Tasks.Escript.Build.run []
      assert_received {:mix_shell, :info, ["Generated escript escriptest"]}
      assert System.cmd("escript", ["escriptest"]) == {"TEST\n", 0}

      Mix.Tasks.Escript.Build.run []
      refute_received {:mix_shell, :info, ["Generated escript escriptest"]}
    end
  end

  test "generate simple escript with path" do
    Mix.Project.push EscriptWithPath

    in_fixture "escripttest", fn ->
      Mix.Tasks.Escript.Build.run []
      assert_received {:mix_shell, :info, ["Generated escript ebin/escripttestwithpath"]}
      assert System.cmd("escript", ["ebin/escripttestwithpath"]) == {"TEST\n", 0}
    end
  end

  test "generate escript with deps" do
    Mix.Project.push EscriptWithDeps

    in_fixture "escripttest", fn ->
      Mix.Tasks.Escript.Build.run []
      assert_received {:mix_shell, :info, ["Generated escript ebin/escripttestwithdeps"]}
      assert System.cmd("escript", ["ebin/escripttestwithdeps"]) == {"TEST\n", 0}
    end
  after
    purge [Ok.Mixfile]
  end
end
