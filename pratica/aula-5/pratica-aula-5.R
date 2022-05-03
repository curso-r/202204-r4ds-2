library(readr)
library(purrr)
library(dplyr)
library(ggplot2)
library(tidyr)

# Motivacao: ler e empilhar as bases IMDB separadas por ano --------

# abrindo só um arquivo
read_rds("data-raw/imdb_por_ano/imdb_1916.rds")

# criando um vetor dos arquivos por ano da base do imdb
# com base R
arquivos <- list.files(path = "data-raw/imdb_por_ano",
                       pattern = ".rds$",
                       full.names = TRUE)

# com o pacote fs
arquivos_com_fs <- fs::dir_ls(path = "data-raw/imdb_por_ano", glob = "*.rds")

# fs::dir_tree()

# estrutura com purrr:
#   map(vetor, funcao)

# só com map: gera uma lista de tibbles
lista_de_tibbles <- map(arquivos, read_rds)


# com bind_rows: gera uma tibble
tibbles_unica <- map(arquivos, read_rds) %>%
  bind_rows()

# com map_dfr, nao é preciso usar o bind_rows
imdb_purrr <- map_dfr(arquivos, read_rds)

# Dúvida da Larissa --------
# E como abrir outros arquivos que não tem  mesma estrutura?
arquivos_com_fs_duvida <- fs::dir_ls("data-raw/", glob = "*.rds")

bases_duvida <- map(arquivos_com_fs_duvida, read_rds)

bases_duvida[[2]]

# como dezipar? duvida 2 -------
unzip("data-raw/imdb_por_ano2.zip", exdir = "data-raw/")


# Motivação: fazer gráficos de dispersão do orçamento vs receita para todos os
# anos da base!

imdb <- read_rds("data-raw/imdb.rds")

# agrupar e fazer um nest  (aninhando pelo grupo) por ano
imdb_por_ano <- imdb %>%
  drop_na(receita, orcamento) %>%
  group_by(ano) %>%
  nest()

imdb_por_ano$data[[1]]

# imdb_por_ano %>%
#   unnest(cols = "data")

# um grafico de dispersao de orcamento e receita

# funcao para fazer o grafico!
fazer_grafico_dispersao <- function(tab_imdb) {
  tab_imdb %>%
    ggplot() +
    aes(x = orcamento, y = receita) +
    geom_point()
}

# experimentando a funcao
fazer_grafico_dispersao(imdb)

# usando map para gerar um gráfico por ano
imdb_graficos <-  imdb_por_ano %>%
  mutate(
    grafico = map(data, fazer_grafico_dispersao)
  )

# acessando os gráficos com base
imdb_graficos$grafico[[3]]

# acessando os gráficos com o pluck
pluck(imdb_graficos, "grafico", 1)

# Motivacao : rodar um modelo para varios grupos -------------

# base que usaremos
mtcars

# exemplo de uso da funcao lm
lm(mpg ~ ., data = mtcars) %>%
  broom::tidy()

# criando uma função para rodar o lm
rodar_lm <- function(tab_mtcars) {
  lm(mpg ~ ., data = tab_mtcars) %>%
    broom::tidy()
}

# agrupando, fazendo nest (aninhando pelo grupo), e usando map para rodar um
# modelo por grupo
modelos_cyl <- mtcars %>%
  group_by(cyl) %>%
  nest() %>%
  mutate(
    modelo = map(data, rodar_lm)
  )

# usando pluck para acessar os resultados
pluck(modelos_cyl, "modelo", 1)

# vendo os resultados para todos os grupos
modelos_cyl  %>% unnest(cols = modelo)

# e se quiser para algum grupo especifico?
# continua sendo uma tibble! podemos filtrar

modelos_cyl %>% filter(cyl == 8) %>% unnest(cols = modelo)


# outra forma de fazer a mesma coisa, sem criar uma função!! ---------

# lembrando da funcao que tinha feito antes:
# rodar_lm <- function(tab_mtcars) {
#   lm(mpg ~ ., data = tab_mtcars) %>%
#     broom::tidy()
# }

# criando uma função anônima com ~ (o argumento tem que ser .x)
mtcars %>%
  group_by(cyl) %>%
  nest() %>%
  mutate(modelo = map(data, ~ broom::tidy(lm(mpg ~ ., data = .x))))

# criando uma função anônima com \() (o argumento pode ter o nome que quisermos,
# e podemos ter vários argumentos)
mtcars %>%
  group_by(cyl) %>%
  nest() %>%
  mutate(modelo = map(data, \(x) broom::tidy(lm(mpg ~ ., data = x))))


# outro exemplo do gráfico de dispersão: com a função group_split()

# primeiro para entender o que o group_split faz:
# vai separar por grupos, cada grupo vira uma lista.
imdb %>%
  group_split(ano)


# podemos usar um map para aplicar uma função em cada elemento da lista.
# ex: contar numero de linhas
imdb %>%
  group_split(ano) %>%
  map(nrow)


# criando uma função anonima para fazer um ggplot:

imdb_split_grafico <- imdb %>%
  drop_na(orcamento, receita) %>%
  group_split(ano) %>%
  map(~ ggplot(data = .x) +
        aes(x = orcamento, y = receita) +
        geom_point() +
        facet_wrap(~ano))

# acessando os gráficos com pluck
grafico_2016 <- pluck(imdb_split_grafico, 69)

# DICA: Podemos acessar os dados usados para gerar um grafico
# usando: objeto_ggplot$data
# exemplo:
grafico_2016$data
