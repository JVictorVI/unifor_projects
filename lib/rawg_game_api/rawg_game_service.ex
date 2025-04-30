defmodule KojimaBot.GameService do

  alias Nostrum.Struct.Embed, as: Container
  alias HTTPoison, as: HTTP

  def get_game_data(game_title) do

    rawg_api_key = "9abafff436824bf3a1640143b627b58a"
    result = HTTP.get("https://api.rawg.io/api/games?key=#{rawg_api_key}&search=#{game_title}")

    case result do
      {:ok, response} ->
        case Jason.decode(response.body) do
          {:ok, json} ->
            case json["results"] do
              [found_game | _] ->

                platforms =
                  found_game["platforms"]
                  |> List.wrap()
                  |> Enum.map(fn platform -> platform["platform"]["name"] end)
                  |> Enum.join(", ")

                stores =
                  found_game["stores"]
                  |> List.wrap()
                  |> Enum.map(fn store -> store["store"]["name"] end)
                  |> Enum.join(", ")

                genres =
                  found_game["genres"]
                  |> List.wrap()
                  |> Enum.map(fn genre -> genre["name"] end)
                  |> Enum.join(", ")

                embed =
                  %Container{}
                  |> Container.put_title("Encontrei o jogo #{found_game["name"]}!")
                  |> Container.put_image("#{found_game["background_image"]}")
                  |> Container.put_color(0x0074E7)

                  |> Container.put_description("Informações encontradas sobre o jogo:")

                  |> Container.put_field(
                    "Data de lançamento",
                    case String.trim(format_date_br(found_game["released"])) do
                      "" -> "TBD"
                      date -> date
                    end,
                    true
                  )

                  |> Container.put_field("Metacritic", found_game["metacritic"] || "TBD", true)

                  |> Container.put_field(
                        "Gêneros",
                        case genres do
                          nil -> "TBD"
                          "" -> "TBD"
                          genres_list -> genres_list
                        end,
                        true
                      )

                  |> Container.put_field(
                    "Plataformas",
                    case platforms do
                      nil -> "TBD"
                      "" -> "TBD"
                      platforms_list -> platforms_list
                      end,
                      true
                    )

                    |> Container.put_field(
                      "Lojas",
                      case stores do
                        nil -> "TBD"
                        "" -> "TBD"
                        stores_list -> stores_list
                        end,
                        true
                      )

                  |> Container.put_url("https://rawg.io/games/#{found_game["id"]}")
                  |> Container.put_footer("Fonte: RAWG")

                embed

              _ ->
                embed =
                  %Container{}
                  |> Container.put_title("Não consegui encontrar o jogo '#{game_title}'...")
                  |> Container.put_image("https://pbs.twimg.com/media/FvQ4S6kWwAA4QPZ.jpg")
                  |> Container.put_description("Tente novamente com outro nome de jogo!")
                  |> Container.put_color(0xFF0000)
            end
        end

      {:error, _} ->
        embed =
          %Container{}
          |> Container.put_title("Erro ao consultar a RAWG API. Tente novamente mais tarde.")
          |> Container.put_color(0xFF0000)
    end
  end

  def get_game_title(content) do
    command = String.split(content, " ", parts: 2)

    case command do
      ["!game", game_title] -> game_title
      _ -> :error
    end
  end

  def format_date_br(date_string) do
    [year, month, day] = String.split(date_string, "-")
    "#{day}/#{month}/#{year}"
  end
end
