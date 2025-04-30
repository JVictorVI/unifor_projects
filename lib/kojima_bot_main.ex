# run `mix run --no-halt` to start the bot

defmodule KojimaBot do

  use Nostrum.Consumer
  alias Nostrum.Api

  alias KojimaBot.CepService
  alias KojimaBot.GameService
  alias KojimaBot.WeatherService
  alias KojimaBot.CurrencyService
  alias KojimaBot.HolidaysService
  alias KojimaBot.DeepseekService
  alias KojimaBot.GeminiService

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
              },
              %{
                name: "!feriados <uf> <ano>",
                value: "Use este para receber informações sobre os feriados nacionais e locais.",
                inline: true
              }

            ],
            author: %{
              name: "KojimaBot"
            }
          }

          Api.Message.create(msg.channel_id, %{
            embed: embed
          })

      # RAWG API
      String.starts_with?(msg.content, "!game") ->
        game_title = GameService.get_game_title(msg.content)

        case game_title do
          :error ->
            Api.Message.create(msg.channel_id, "Comando inválido. Use !game <nome_do_jogo>.")

          _ ->
            game_data = GameService.get_game_data(game_title)
            Api.Message.create(msg.channel_id, embed: game_data)
        end


      # Weather API
      String.starts_with?(msg.content, "!clima") ->
        city_name = WeatherService.get_city_name(msg.content)

        case city_name do
          :error ->
            Api.Message.create(msg.channel_id, "Comando inválido. Use !clima <nome_da_cidade>.")

          _ ->
            weather_data = WeatherService.get_weather_data(msg.channel_id, city_name)
            Api.Message.create(msg.channel_id, embed: weather_data)
        end

      # Deepseek API
      String.starts_with?(msg.content, "!deepseek") ->
        question = DeepseekService.get_question(msg.content)

        case question do
          :error ->
            Api.Message.create(msg.channel_id, "Comando inválido. Use !deepseek <sua_pergunta>.")

          _ ->
            response = DeepseekService.send_deepseek_message(msg.channel_id, question)
            Api.Message.create(msg.channel_id, embed: response)
        end

      # Currency API
      String.starts_with?(msg.content, "!cambio") ->

        case CurrencyService.validate_currency(msg.content) do

          :error ->
            Api.Message.create(msg.channel_id, "Comando inválido. Use !cambio <valor> <moeda_origem> <moeda_destino>.")

          {value, from_currency, to_currency} ->
            currency_data = CurrencyService.get_currency_data(value, from_currency, to_currency)
            Api.Message.create(msg.channel_id, embed: currency_data)
        end

      String.starts_with?(msg.content, "!moedas") ->
        currencies = CurrencyService.get_available_currencies()
        Api.Message.create(msg.channel_id, embed: currencies)

      # Feriados
      String.starts_with?(msg.content, "!feriados") ->

        case HolidaysService.validate_holiday(msg.content) do

          :error ->
            Api.Message.create(msg.channel_id, "Comando inválido. Use !feriados <uf> <ano>.")

          {uf, year} ->
            holiday_data = HolidaysService.get_holiday_data(uf, year)
            Api.Message.create(msg.channel_id, embed: holiday_data)

        end

      #ExP
      String.starts_with?(msg.content, "!gemini") ->

        question = GeminiService.get_question(msg.content)
        image_url = GeminiService.get_url_img(msg.attachments)

        response = GeminiService.get_gemini_response(msg.channel_id, question, image_url)

        Api.Message.create(msg.channel_id, "Você perguntou #{question} e mandou a imagem: #{image_url}")

      true ->
        :ignore
    end
  end
end
