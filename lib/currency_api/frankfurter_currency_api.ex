defmodule KojimaBot.CurrencyService do

  alias Nostrum.Struct.Embed, as: Container
  alias HTTPoison, as: HTTP

  def validate_currency(content) do

    command =
      String.replace(content, "!cambio", "")
      |> String.trim()

    parts = String.split(command, " ", trim: true)

    case parts do
      [value, from_currency, to_currency] -> {value, from_currency, to_currency}
      _ -> :error
    end
  end

  def get_available_currencies() do
    result = HTTP.get("https://api.frankfurter.dev/v1/currencies")
    case result do
      {:ok, response} ->
        case Jason.decode(response.body) do
          {:ok, json} ->

            %Container{}
            |> Container.put_title("Lista de Moedas Disponíveis")
            |> Container.put_color(0x0074E7)
            |> Container.put_description("Fonte: European Central Bank")
            |> Container.put_field(
              "Moedas",
              Enum.map(json, fn {key, value} -> "#{key} - #{value}" end)
              |> Enum.join("\n"),
              true
            )
            |> Container.put_footer("Use !cambio <valor> <moeda_origem> <moeda_destino> para consultar o câmbio.")

          _ ->
            %Container{}
            |> Container.put_title("Erro")
            |> Container.put_color(0xFF0000)
            |> Container.put_description("Erro ao interpretar a resposta da API.")
            |> Container.put_footer("Tente novamente mais tarde.")
        end

      {:error, _} ->
        %Container{}
        |> Container.put_title("Erro")
        |> Container.put_color(0xFF0000)
        |> Container.put_description("Erro ao consultar a API de câmbio.")
        |> Container.put_footer("Tente novamente mais tarde.")
    end
  end

  def get_currency_data(value, from_currency, to_currency) do

    from_currency = String.upcase(from_currency)
    to_currency = String.upcase(to_currency)

    result = HTTP.get("https://api.frankfurter.dev/v1/latest?amount=#{value}&base=#{from_currency}&symbols=#{to_currency}")
    case result do
      {:ok, response} ->
        case JSON.decode(response.body) do

          {:ok, %{"message" => _}} ->
            embed =
              %Container{}
              |> Container.put_title("Erro")
              |> Container.put_color(0xFF0000)
              |> Container.put_description("Um dos valores foi enviado incorretamente.
              Verifique os códigos das moedas e o valor da conversão e tente novamente.")

          {:ok, json} ->

            embed =
              %Container{}
              |> Container.put_title("Conversão de Moeda")
              |> Container.put_color(0x0074E7)
              |> Container.put_field(
                "Câmbio",
                "#{value} #{json["base"]} equivale a #{json["rates"][to_currency]} #{to_currency}",
                true
              )
              |> Container.put_footer("Fonte: Frankfurter API | European Central Bank")

          _ ->
            embed =
              %Container{}
              |> Container.put_title("Erro ao consultar câmbios")
              |> Container.put_color(0xFF0000)
              |> Container.put_description("Erro ao interpretar a resposta da API.")
              |> Container.put_footer("Tente novamente mais tarde.")
          end

      {:error, _} ->
        embed = %Container{}
          |> Container.put_title("Erro ao consultar câmbios")
          |> Container.put_color(0xFF0000)
          |> Container.put_description("Erro ao consultar a API Frankfurter.")
          |> Container.put_footer("Tente novamente mais tarde.")
    end
  end
end
