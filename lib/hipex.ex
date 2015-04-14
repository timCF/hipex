defmodule Hipex do
  require Exutils
  use Application
  @host :application.get_env(:hipex, :host, nil)

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    if not(is_binary(@host)), do: raise "#{__MODULE__} : plz define host for hipex in config.exs"

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Hipex.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hipex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def notice(bin) when is_binary(bin), do: message("green", bin)
  def warn(bin) when is_binary(bin), do: message("yellow", bin)
  def error(bin) when is_binary(bin), do: message("red", bin)

  defp message(color, bin) do
    case HTTPoison.post(@host, %{message: bin, color: color} |> Jazz.encode!, %{"Content-type" => "application/json"}) |> Exutils.safe do
      {:ok, %HTTPoison.Response{status_code: 200}} -> :ok
      {:ok, %HTTPoison.Response{status_code: 204}} -> :ok
      error -> {:error, error}
    end
  end

end
