defmodule KojimaBot.HolidaysService do

  alias Nostrum.Struct.Embed, as: Container
  alias HTTPoison, as: HTTP

  def validate_holiday(content) do

    command =
      String.replace(content, "!feriados", "")
      |> String.trim()

    parts = String.split(command, " ", trim: true)

    case parts do
      [uf, year] -> {uf, year}
      _ -> :error
    end
  end

  def get_holiday_data(uf, year) do

    token = "19184|qov8ZWZtkQqsTI9l739mqADVqVUP6Q4r"
    result = HTTP.get("https://api.invertexto.com/v1/holidays/#{year}?token=#{token}&state=#{uf}")

    case result do
      {:ok, response} ->
        case JSON.decode(response.body) do
          {:ok, json} ->

            %Container{}
            |> Container.put_title("Feriados disponíveis em #{String.upcase(uf)} - #{year}")
            |> Container.put_field(
              "Feriados",
              Enum.map(json, fn holiday -> "**#{format_date_br(holiday["date"])}** - #{holiday["name"]}" end)
              |> Enum.join("\n"),
              true
            )
            |> Container.put_color(0x0074E7)
            |> Container.put_footer("Fonte: Invertexto")

            _ ->
              %Container{}
              |> Container.put_title("Erro ao consultar feriados")
              |> Container.put_color(0xFF0000)
              |> Container.put_description("Erro ao interpretar a resposta da API Invertexto.")
              |> Container.put_footer("Tente novamente mais tarde.")

        end

      {:error, _} ->
        %Container{}
        |> Container.put_title("Erro ao consultar feriados")
        |> Container.put_color(0xFF0000)
        |> Container.put_description("Erro ao consultar a API de Feriados.")
        |> Container.put_footer("Tente novamente mais tarde.")
    end


  end

  def format_date_br(date_string) do
    [year, month, day] = String.split(date_string, "-")
    "#{day}/#{month}/#{year}"
  end

end
