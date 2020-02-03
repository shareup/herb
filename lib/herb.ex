defmodule Herb do
  @moduledoc """
  Herb allows one to fetch, compile, and require mix projects (including hex
  packages) outside a mix project.
  """

  @doc false
  def main(args \\ []) do
    with {:ok, file_path, new_args} <- extract_file_path_arg(args),
         :ok <- System.argv(new_args),
         :ok <- setup() do
      Code.eval_file(file_path)
    else
      {:usage, code} ->
        usage()
        exit({:shutdown, code})

      :error ->
        exit({:shutdown, 1})
    end
  end

  defp usage do
    IO.puts(:stderr, """
    Usage: herb [file] [args passed to file]
    """)
  end

  defp extract_file_path_arg([]) do
    {:usage, 0}
  end

  defp extract_file_path_arg([file_path | rest_args]) do
    if File.exists?(file_path) do
      {:ok, file_path, rest_args}
    else
      IO.puts(:stderr, "No file at #{file_path}")
      :error
    end
  end

  @doc """
  Set up the environment necessary to be able to install and load packages with
  mix and hex.

  Returns `:ok`.
  """
  def setup do
    with :ok <- File.mkdir_p!(packages_dir()),
         :ok <- start_apps([:mix]),
         :ok <- make_prod(),
         true <- append_archive_code_paths(),
         :ok <- start_apps([:hex]) do
      :ok
    end
  end

  @doc """
  Fetch, compile, and require a package from hex.

  Returns `:ok`.
  """
  def package(name, version) do
    File.cd!(packages_dir(), fn ->
      package_name = "#{name}-#{version}"

      unless File.dir?(package_name) do
        fetch(name, version)
      end

      load_project(name, package_name)
    end)
  end

  @doc """
  Compile and require a project on disk at a path.

  Returns `:ok`.
  """
  def path(name, path), do: load_project(name, path)

  defp load_project(name, path) do
    Mix.Project.in_project(name, path, fn _module ->
      ebin = Mix.Project.compile_path()

      unless File.dir?(ebin) do
        Mix.Dep.Fetcher.all(%{}, Mix.Dep.Lock.read(), env: :prod)
        Mix.Project.compile([])
      end

      Code.append_path(ebin)
    end)

    start_apps([name])
  end

  # Force things to be as-if MIX_ENV=prod
  defp make_prod do
    Mix.State.put(:env, :prod)
    :ok
  end

  # This function is just making this line shorter where it's used
  defp fetch(name, version) do
    Mix.Tasks.Hex.Package.run(["fetch", to_string(name), version, "--unpack"])
  end

  defp packages_dir do
    [System.user_home!(), ".herb", "packages"]
    |> Path.join()
  end

  # For some reason, hex's archive is not in the load path by default
  defp append_archive_code_paths do
    Mix.path_for(:archives)
    |> Path.join("*")
    |> Path.wildcard()
    |> Enum.each(&append_archive_code_path/1)
  end

  defp append_archive_code_path(archive_path) do
    ebin_path =
      [archive_path, Path.basename(archive_path), "ebin"]
      |> Path.join()

    Code.append_path(ebin_path)
  end

  defp start_apps([]), do: :ok

  defp start_apps([name | rest]) do
    case Application.ensure_all_started(name) do
      {:ok, _} ->
        start_apps(rest)

      other ->
        other
    end
  end
end
