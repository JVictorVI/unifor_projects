# run `mix run --no-halt` to start the bot

defmodule KojimaBot do

  use Nostrum.Consumer
  alias Nostrum.Api

  alias KojimaBot.CepService
  alias KojimaBot.GameService
  alias KojimaBot.WeatherService
  alias KojimaBot.CurrencyService

  alias Nostrum.Struct.Embed, as: Container
  alias HTTPoison, as: HTTP

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    cond do

      # Saudações
      String.starts_with?(msg.content, "!oi") ->
          embed = %{
            title: "Olá, #{msg.author.username}!",
            description: "Tudo bem dog? Eu sou o KojimaBot, e esses são meus
            comandos disponíveis!",
            color: 0x0074E7,
            fields: [
              %{
                name: "!cep <valor_do_cep>",
                value: "Use este para receber informações sobre o CEP.",
                inline: true
              },
              %{
                name: "!game <nome_do_jogo>",
                value: "Use este para receber informações sobre um jogo.",
                inline: true
              },
              %{
                name: "!clima <nome_da_cidade>",
                value: "Use este para receber informações sobre o clima.",
                inline: true
              },
              %{
                name: "!cambio <valor> <moeda_origem> <moeda_destino>",
                value: "Use este para receber informações sobre o câmbio entre duas moedas.",
                inline: true
              },
              %{
                name: "!moedas",
                value: "Use este para receber informações sobre todas as moedas disponíveis para conversão.",
                inline: true
              }

            ],
            author: %{
              name: "KojimaBot"
            }
          }

          Api.create_message(msg.channel_id, %{
            embed: embed
          })

      # CEP API
      String.starts_with?(msg.content, "!cep") ->
        cep_value = CepService.validate_cep(msg.content)
        cep_data = CepService.get_cep_data(cep_value)
        Api.create_message(msg.channel_id, cep_data)

      # RAWG API
      String.starts_with?(msg.content, "!game") ->
        game_title = GameService.get_game_title(msg.content)

        case game_title do
          :error ->
            Api.create_message(msg.channel_id, "Comando inválido. Use !game <nome_do_jogo>.")

          _ ->
            game_data = GameService.get_game_data(game_title)
            Api.create_message(msg.channel_id, embed: game_data)
        end


      # Weather API
      String.starts_with?(msg.content, "!clima") ->
        city_name = WeatherService.get_city_name(msg.content)

        case city_name do
          :error ->
            Api.create_message(msg.channel_id, "Comando inválido. Use !clima <nome_da_cidade>.")

          _ ->
            weather_data = WeatherService.get_weather_data(city_name)
            Api.create_message(msg.channel_id, embed: weather_data)
        end

      # Currency API
      String.starts_with?(msg.content, "!cambio") ->

        case CurrencyService.validate_currency(msg.content) do

          :error ->
            Api.create_message(msg.channel_id, "Comando inválido. Use !cambio <valor> <moeda_origem> <moeda_destino>.")

          {value, from_currency, to_currency} ->
            currency_data = CurrencyService.get_currency_data(value, from_currency, to_currency)
            Api.create_message(msg.channel_id, embed: currency_data)
        end

      String.starts_with?(msg.content, "!moedas") ->
        currencies = CurrencyService.get_available_currencies()
        Api.create_message(msg.channel_id, embed: currencies)

      true ->
        :ignore
    end
  end
end
