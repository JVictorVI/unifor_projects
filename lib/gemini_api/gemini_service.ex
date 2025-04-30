# c7232ff3370b26064fc1485413deeabb

defmodule KojimaBot.GeminiService do

  use Nostrum.Consumer
  alias Nostrum.Api

  alias Nostrum.Struct.Embed, as: Container
  alias HTTPoison, as: HTTP

  def get_gemini_response(channel_id, question, image_url) do
    token = "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"
    url = "https://openrouter.ai/api/v1/chat/completions"

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"}
    ]

    body = Jason.encode!(%{
      "model" => "meta-llama/llama-4-maverick:free",
      "messages" => [
        %{
          "role" => "system",
          "content" => "Responda sempre em PT-BR."
        },
        %{
          "role" => "user",
          "content" => [
            %{
              "type" => "text",
              "text" => question
             },

            %{
              "type" => "image_url",
              "image_url" => url
             },
          ]
        }
      ]
    })

    {:ok, message} = Api.Message.create(channel_id, "Gerando uma resposta. Um momento...")

    result = HTTP.post(url, body, headers)

    case result do
      {:ok, response} ->
        Api.Message.delete(channel_id, message.id)
        case Jason.decode(response.body) do

          {:ok, json} ->
            IO.inspect(json)

        end
      end

  end

  def get_question(content) do

    command = String.split(content, " ", parts: 2)
    case command do
      ["!gemini", question] -> question
      _ -> :error
    end
  end

  def get_url_img(attachments) do

     case attachments do
      [attachment | _] -> attachment.url
      [] -> :error
     end
  end

end
