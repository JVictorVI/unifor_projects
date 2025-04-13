defmodule KojimaBot.CepService do

  alias HTTPoison, as: HTTP

  def validate_cep(content) do
    command = String.split(content, " ")

    case command do
      ["!cep", cep_value] -> cep_value
      _ -> :error
    end
  end

  def get_cep_data(cep_value) do

    result = HTTP.get("viacep.com.br/ws/#{cep_value}/json/")

    case result do
      {:ok, response} ->
        case JSON.decode(response.body) do
          {:ok, %{"erro" => true}} ->
            "CEP não encontrado."

          {:ok, json} ->
            "#{json["logradouro"]}, #{json["bairro"]}, #{json["localidade"]}, #{json["uf"]}"

          {:error, _} ->
            "Erro ao interpretar a resposta da API."
        end

      {:error, %HTTP.Error{reason: :nxdomain}} ->
        "Erro de domínio: verifique a URL da API."

      {:error, _reason} ->
        "Erro ao consultar a API do ViaCEP."
    end
  end
end
