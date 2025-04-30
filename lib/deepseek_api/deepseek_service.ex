defmodule KojimaBot.DeepseekService do

  use Nostrum.Consumer
  alias Nostrum.Api

  alias Nostrum.Struct.Embed, as: Container
  alias HTTPoison, as: HTTP

  def get_question(content) do

    command = String.split(content, " ", parts: 2)
    case command do
      ["!deepseek", question] -> question
      _ -> :error
    end
  end

  def send_deepseek_message(channel_id, question) do
    token = "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"
    url = "https://openrouter.ai/api/v1/chat/completions"

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"}
    ]

    body = Jason.encode!(%{
      "model" => "deepseek/deepseek-r1-zero:free",
      "messages" => [
        %{
          "role" => "system",
          "content" => "Gere respostas curtas e resumidas em parágrafos. Gere respostas sem nenhum tipo de formatação de texto, tais como negrito, aspas, dentre outras. Responda sempre em PT-BR."
        },
        %{
          "role" => "user",
          "content" => question
        }
      ]
    })

    {:ok, message} = Api.Message.create(channel_id, "Gerando uma resposta. Um momento...")

    result = HTTP.post(url, body, headers)

    case result do
      {:ok, response} ->
        Api.Message.delete(channel_id, message.id)
        case Jason.decode(response.body) do

          {:ok, %{"error" => _}} ->
            %Container{}
              |> Container.put_title("Erro ao processar sua pergunta")
              |> Container.put_description("O número de tokens gratuito foram atingidos. Tente novamente mais tarde.")
              |> Container.put_color(0xFF0000)

          {:ok, json} ->
            response = json["choices"]
                       |> List.first()
                       |> Map.get("message")
                       |> Map.get("content")
                       |> formatar_msg()

            %Container{}
            |> Container.put_title(String.upcase(question))
            |> Container.put_description(response)
            |> Container.put_color(0x0074E7)
            |> Container.put_footer("Fonte: Deepseek | OpenRouter")

          _ ->
            %Container{}
              |> Container.put_title("Erro ao processar sua pergunta")
              |> Container.put_description("Tente novamente mais tarde.")
              |> Container.put_color(0xFF0000)
        end

        {:error, _} ->
          %Container{}
          |> Container.put_title("Erro ao consultar a API do Deepseek. Tente novamente mais tarde.")
          |> Container.put_color(0xFF0000)
    end
  end

  def formatar_msg(content) do
    content
    |> String.replace(~r/^\\boxed\{/, "")
    |> String.replace(~r/\}$/, "")
    |> String.replace("\"", "")
  end

end
