library(readr)
library(dplyr)
library(ggplot2)
library(forcats)
library(lubridate)

# EXPLORANDO LUBRIDATE
# CETESB --------------------

cetesb <- read_rds("data-raw/cetesb.rds")

glimpse(cetesb)

# Pinheiros
# Ozonio
o3_pinheiros <- cetesb %>%
  filter(estacao_cetesb == "Pinheiros", poluente == "O3") %>%
  mutate(
    ano = year(data),
    mes = month(data),
    dia_do_mes = day(data),
    dia_semana = wday(data)
  )

# gráfico de linhas simples - muita informação!
o3_pinheiros %>%
  ggplot() +
  aes(x = data, y = concentracao) +
  geom_line()


# Sumarizando por ano
o3_pinheiros %>%
  group_by(ano) %>%
  summarise(media_o3 = mean(concentracao, na.rm = TRUE))


# Sumarizando por mes
o3_pinheiros %>%
  group_by(mes) %>%
  summarise(media_o3 = mean(concentracao, na.rm = TRUE))

# grafico com as medias por mes (considerando todos os anos)
o3_pinheiros %>%
  group_by(mes) %>%
  summarise(media_o3 = mean(concentracao, na.rm = TRUE)) %>%
  ggplot() +
  aes(x = mes, y = media_o3) +
  geom_col()


o3_pinheiros %>%
  mutate(mes_ano = floor_date(data, "month")) %>%
  group_by(mes_ano) %>%
  summarise(media = mean(concentracao, na.rm = TRUE)) %>%
  ggplot() +
  aes(x = mes_ano, y = media) +
  geom_line() +
  scale_x_date(date_breaks = "6 months", date_labels = "%m/%y")


# faceting

o3_pinheiros %>%
  mutate(dia_semana = wday(data,
                           label = TRUE,
                           abbr = FALSE,
                           locale = "pt_BR.UTF-8" # no mac e linux
                           # locale = "Portuguese_Brazil.1252" # no windows
                           )) %>%
  group_by(hora, dia_semana) %>%
  summarise(media = mean(concentracao, na.rm = TRUE)) %>%
  ggplot() +
  aes(x = hora, y = media) +
  geom_line() +
  facet_wrap(vars(dia_semana))

# ----------------
# EXPLORANDO FORCATS

imdb <- read_rds("data-raw/imdb.rds")

# ordenar por uma categoria ordinal
# grafico de classificacao dos filmes
imdb %>% glimpse()

imdb %>%
  mutate(classificacao_fator = fct_relevel(classificacao,
                                         c("Livre", "A partir de 13 anos",
                                           "A partir de 18 anos", "Outros"))) %>%
  count(classificacao_fator) %>%
  ggplot() +
  aes(x = classificacao_fator, y = n) +
  geom_col()


# ordenar por frequencia
# quais sao os generos mais lucrativos nessa base!

imdb %>%
  mutate(lucro = receita - orcamento) %>%
  tidyr::drop_na(lucro) %>%
  tidyr::separate_rows(generos, sep = "\\|") %>%
  group_by(generos) %>%
  summarise(lucro_medio = mean(lucro)) %>%
  mutate(generos = fct_reorder(generos, lucro_medio)) %>%
  ggplot() +
  aes(y = generos, x = lucro_medio) +
  geom_col()


imdb %>%
  mutate(lucro = receita - orcamento) %>%
  tidyr::drop_na(lucro) %>%
  tidyr::separate_rows(generos, sep = "\\|") %>%
  mutate(generos = fct_lump(generos, n =  18)) %>%
  group_by(generos) %>%
  summarise(lucro_medio = mean(lucro)) %>%
  mutate(generos = fct_reorder(generos, lucro_medio)) %>%
  ggplot() +
  aes(y = generos, x = lucro_medio) +
  geom_col()
