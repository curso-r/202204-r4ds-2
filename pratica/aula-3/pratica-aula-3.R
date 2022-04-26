library(dplyr)
library(stringr)

# Exemplos IMDB -----
imdb <- readr::read_rds("data-raw/imdb.rds")

# detectar filmes que contém numeros nos titulos
imdb %>%
  filter(str_detect(string = titulo, pattern = "[0-9]")) %>%
  View()

# detectar filmes que o titulo começa com números
imdb %>%
  filter(str_detect(string = titulo, pattern = "^[0-9]")) %>%
  View()

# contar quantos gêneros cada filme tem?

imdb %>%
  select(titulo, generos) %>%
  mutate(contagem_de_generos = str_count(generos, pattern = "\\|") + 1)

# extrair os subtítulos dos filmes!!!
# testamos a sugestão com str_split e não é tao legal porque gera uma lista
imdb %>%
  select(titulo) %>%
  filter(str_detect(titulo, ":")) %>%
  mutate(subtitulo = str_split(titulo, pattern = ":", simplify = TRUE)) %>%
  tidyr::unnest(subtitulo) %>%
  setNames(c("titulo_completo", "titulo", "subtitulo"))



filmes_com_subtitulo <- imdb %>%
  select(titulo) %>%
  filter(str_detect(titulo, ":"))

# isso ajuda a descobrir/testar padroes!
str_view(filmes_com_subtitulo$titulo, pattern = ":.+")


filmes_com_subtitulo %>%
  mutate(subtitulo = str_extract(titulo, pattern = ":.+"),
         subtitulo = str_remove(subtitulo, ": "))



# Exemplo com a base do Rick and Morty -------------------
# código inicial aqui: https://raw.githubusercontent.com/curso-r/main-r4ds-2/master/data-raw/rick_and_morty_raw.R

# carregar os pacotes
library(magrittr)
library(dplyr)
library(stringr)

# faz o scraper
url <-
  "https://en.wikipedia.org/wiki/List_of_Rick_and_Morty_episodes"

res <- httr::GET(url)

wiki_page <- httr::content(res)

lista_tab <- wiki_page %>%
  xml2::xml_find_all(".//table") %>%
  magrittr::extract(2:6) %>%
  rvest::html_table(fill = TRUE) %>%
  purrr::map(janitor::clean_names) %>%
  purrr::map( ~ dplyr::rename_with(.x, ~ stringr::str_remove(.x, "_37|_3")))

num_temporadas <- 1:length(lista_tab)

tab <- lista_tab %>%
  purrr::map2(num_temporadas, ~ dplyr::mutate(.x, no_season = .y)) %>%
  dplyr::bind_rows()


# dplyr::glimpse(tab)
# Rows: 51
# Columns: 8
# $ no_overall           <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
# $ no_inseason          <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 1, 2, 3, …
# $ title                <chr> "\"Pilot\"", "\"Lawnmower Dog\"", "\"Anatomy…
# $ directed_by          <chr> "Justin Roiland", "John Rice", "John Rice", …
# $ written_by           <chr> "Dan Harmon & Justin Roiland", "Ryan Ridley"…
# $ original_air_date    <chr> "December 2, 2013 (2013-12-02)", "December 9…
# $ u_s_viewers_millions <chr> "1.10[4]", "1.51[5]", "1.30[6]", "1.32[7]", …
# $ no_season            <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2,…


# Objetivo: Limpar a base `tab` e criar essa tabela:
# > dplyr::glimpse(rick_and_morty)
# Rows: 51
# Columns: 8
# $ num_episodio              <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,…
# $ num_temporada             <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,…
# $ num_dentro_temporada      <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 1, 2, 3, 4, 5, 6, 7, 8, 9, …
# $ titulo                    <chr> "Pilot", "Lawnmower Dog", "Anatomy Park", "M. Night Shaym-Alie…
# $ direcao                   <chr> "Justin Roiland", "John Rice", "John Rice", "Jeff Myers", "Bry…
# $ roteiro                   <chr> "Dan Harmon & Justin Roiland", "Ryan Ridley", "Eric Acosta & W…
# $ data_transmissao_original <date> 2013-12-02, 2013-12-09, 2013-12-16, 2014-01-13, 2014-01-20, 2…
# $ qtd_espectadores_EUA      <dbl> 1.10, 1.51, 1.30, 1.32, 1.61, 1.75, 1.76, 1.48, 1.54, 1.75, 2.…


xtab %>%
  transmute(
    num_episodio = no_overall,
    num_temporada = no_season,
    num_dentro_temporada = no_inseason,
    #titulo = str_remove_all(title, pattern = '"')
    titulo = str_remove_all(title, pattern = "\""),
    direcao = directed_by,
    roteiro = written_by,
    data_transmissao_original = str_extract(original_air_date, "\\([0-9-]*\\)"),
    qtd_espectadores_EUA = str_remove_all(u_s_viewers_millions, "\\[.*\\]")
  ) %>%
  mutate(
    data_transmissao_original = str_remove_all(data_transmissao_original, "\\(|\\)"),
    data_transmissao_original = lubridate::as_date(data_transmissao_original),
    qtd_espectadores_EUA = as.numeric(qtd_espectadores_EUA)
  ) %>%
  glimpse()
