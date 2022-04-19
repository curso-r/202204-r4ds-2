# install.packages("dados")
# Carregando os pacotes usados nos exemplos
library(dados)
library(tidyr)
library(dplyr)
library(readr)
library(ggplot2)

# Exemplo 1: remover NAs com tidyr --------------
# dados de personagens do star wars
dados_starwars %>% View()

# removendo TODAS as linhas que contém algum NA
dados_starwars %>%
  drop_na() %>%
  View()

# removendo as linhas que contém NA nas colunas altura ou massa
dados_starwars %>%
  drop_na(altura, massa) %>%
  View()

# Exemplo 2 ----------------------------------------------------------
# motivação: descobrir o ator ou atriz com o maior lucro médio na base,
# que atuaram em pelo menos 10 filmes

# ler os dados do imdb
imdb <- read_rds("data-raw/imdb.rds")

imdb %>%
  # criar uma coluna com todas as pessoas que atuaram no filme
  # e estão na base
  pivot_longer(
    cols = starts_with("ator"),
    names_to = "posicao",
    values_to = "ator_atriz"
  ) %>%
  # cria a variável lucro
  mutate(lucro = receita - orcamento) %>%
  # remove as linhas que o lucro é NA
  drop_na(lucro) %>%
  # seleciona as colunas relevantes
  select(titulo, ator_atriz, lucro) %>%
  # agrupando por ator/atriz
  group_by(ator_atriz) %>%
  # calculando o lucro médio por ator/atriz e
  # o número de filmes que participaram
  summarise(lucro_medio = mean(lucro, na.rm = TRUE),
            n_filmes = n()) %>%
  # filtrar as pessoas que atuaram em pelo menos 10 filmes
  filter(n_filmes >= 10) %>%
  # ordenar em forma decrescente segundo o lucro
  arrange(desc(lucro_medio))

# Exemplo 3 ---------------------------
# motivação: substituir todos os NAs das variáveis
# categóricas por "sem informação"

# substituindo os NAs de colunas character
dados_starwars %>%
  mutate(across(
    .cols = where(is.character),
    .fns = tidyr::replace_na,
    replace = "sem informação"
  )) %>% View()

# dúvida: como imputar nas variáveis numéricas
# a média da variável no lugar dos NAs?
dados_starwars %>%
  mutate(
    # transformar as colunas integer em double
    across(.cols = where(is.integer),
           .fns = as.double),
    # agora sim podemos substituir o NA pela média
    # para as colunas numéricas
    across(
      .cols = where(is.numeric),
      .fns = ~ tidyr::replace_na(.x, mean(.x, na.rm = TRUE))
    )
  )

# Dúvida: como usar mais de uma condição para selecionar as colunas
# usadas no across?
dados_starwars %>%
  mutate(across(
    .cols = where(is.character) & starts_with("cor"),
    .fns = tidyr::replace_na,
    replace = "sem informação"
  )) %>% View()


# Exemplo 4 ----------------
# motivação: Fazer gráficos de dispersão do lucro vs todas as
# outras variáveis núméricas da base IMDB

imdb %>%
  # criar coluna lucro
  mutate(lucro = receita - orcamento) %>%
  # selecionar as colunas numericas
  select(where(is.numeric)) %>%
  # alterar o formato da base para possibilitar fazer o gráfico
  pivot_longer(
    cols = - lucro,
    names_to = "variavel",
    values_to = "valor"
  ) %>%
  # cria o ggplot
  ggplot() +
  # gráfico de dispersão
  geom_point(aes(x = valor, y = lucro)) +
  # o facet permite criar vários gráficos de uma vez
  facet_wrap(~ variavel, scales = "free")
