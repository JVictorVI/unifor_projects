defmodule KojimaBot.WeatherService do

  alias Nostrum.Struct.Embed, as: Container
  alias HTTPoison, as: HTTP

  def get_weather_data(city_name) do

    city_name = String.replace(city_name, " ", "%20")

    openweathermap_api_key = "83f116f5dfb3cc471e2dbe75a070de5d"
    result = HTTP.get("https://api.openweathermap.org/data/2.5/weather?q=#{city_name}&appid=#{openweathermap_api_key}&units=metric&lang=pt_br")

    case result do
      {:ok, response} ->
        case JSON.decode(response.body) do
          {:ok, json} ->

            icon = json["weather"] |> List.first() |> Map.get("icon")
            weather_description = json["weather"] |> List.first() |> Map.get("description")

            embed =
              %Container{}
              |> Container.put_title("Clima atual de #{json["name"]}!")
              |> Container.put_description("Informações encontradas sobre o clima: **#{weather_description}**")

              |> Container.put_field("Temperatura Atual", "#{json["main"]["temp"]}°C", true)
              |> Container.put_field("Temperatura Mínima", "#{json["main"]["temp_min"]}°C", true)
              |> Container.put_field("Temperatura Máxima", "#{json["main"]["temp_max"]}°C", true)

              |> Container.put_field("Sensação Térmica", "#{json["main"]["feels_like"]}°C", true)
              |> Container.put_field("Umidade", "#{json["main"]["humidity"]}%", true)
              |> Container.put_field("Velocidade do Vento", "#{json["wind"]["speed"]} m/s", true)

              |> Container.put_color(0x0074E7)
              |> Container.put_thumbnail("https://openweathermap.org/img/wn/#{icon}@4x.png")
              |> Container.put_footer("Fonte: OpenWeatherMap")

            _ ->
              embed =
                %Container{}
                |> Container.put_title("Não consegui encontrar a cidade '#{city_name}'...")
                |> Container.put_image("https://pbs.twimg.com/media/GgzaUl0WEAAK-eN.jpg:large")
                |> Container.put_description("Tente novamente com outro nome de cidade!")
                |> Container.put_color(0xFF0000)
      end

      {:error, _} ->
        embed =
          %Container{}
          |> Container.put_title("Erro ao consultar a API OpenWeatherMap. Tente novamente mais tarde.")
          |> Container.put_color(0xFF0000)
    end
  end

  def get_city_name(content) do
    command = String.split(content, " ", parts: 2)
    case command do
      ["!clima", city_name] -> city_name
      _ -> :error
    end
   end

end
