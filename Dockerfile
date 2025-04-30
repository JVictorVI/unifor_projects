FROM elixir:1.18.3-alpine

# Instala dependências do sistema (compiladores e git)
RUN apk add --no-cache build-base git

# Define diretório de trabalho
WORKDIR /usr/src/kojimabot

# Copia arquivos de dependências primeiro (aproveita cache do Docker)
COPY mix.exs mix.lock ./

# Instala Hex, Rebar e dependências do projeto
RUN mix local.hex --force && \
    mix local.rebar --force && \
    MIX_ENV=prod mix deps.get

# Copia o restante do código (só se algo mudou)
COPY . .

# Compila as dependências e o projeto
RUN MIX_ENV=prod mix deps.compile && \
    MIX_ENV=prod mix compile

# Comando padrão para rodar o bot
CMD ["mix", "run", "--no-halt"]
