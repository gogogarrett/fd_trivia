# I think this may need to be provided by flowdock_client package instead of inside this app
defmodule FdTrivia.Service.FetchFlowUsers do
  @moduledoc """
  A service that goes to flowdock api to fetch a list of users for a given flow
  """

  @api_token Application.get_env(:flowdock_client, :api_token)
  @flow_name Application.get_env(:fd_trivia, :flow_name, "testttt")
  @org_name Application.get_env(:fd_trivia, :org_name, "blake")


  def get_users do
    with response <- fetch,
         json_body <- Map.get(response, :body),
         {:ok, players_json} <- Poison.decode(json_body),
         players = Enum.map(players_json, &Map.take(&1, ["id", "nick"]))
    do
      players
    else
      _ ->
        IO.inspect("error loading users")
        []
    end
  end

  defp fetch do
    HTTPotion.get(
      "https://api.flowdock.com/flows/#{@org_name}/#{@flow_name}/users",
      [
        headers: ["Authorization": prepare_auth_header(@api_token)]
      ]
    )
  end

  defp prepare_auth_header(string) do
    auth_string = string |> Base.encode64
    "Basic #{auth_string}"
  end
end
