
l <- list(
  um_numero = 123,
  um_vetor = c(TRUE, FALSE, TRUE),
  uma_string = "abc",
  uma_lista = list(1, 2, 3)
)

l$uma_string
l$uma_lista[[1]]
l[[4]][[3]]

l[["uma_string"]]
aqui <- 2
l[[aqui]]
l$aqui # <- Não funciona!

mtcars$mpg
mtcars[["mpg"]]
mtcars[[1]]
aqui <- "mpg"
mtcars[[aqui]]

vetor <- c(1, 2, 3)
vetor[1:2]

l[[1:2]] # <- Não funciona!
l[1:2]

l[[1]] # Sempre retorna um elemento (elemento)
l[1] # Sempre retorna uma sub-lista (posição)

# |                                 | 1  |  2 |  3  |
# |                                 | C1 | C2 | C3  |
# |                                 |---------------|
# | 123     | T, F, T    | "abc"    | Rua de Boneca |
# | Casa 1  |   Casa 2   |  Casa 3  |    Casa 4     |
# |-------------------------------------------------|
# |         Rua                                     |

l[1:2]
l[[1:2]]
l[1]
l[[1]]

[] -> Endereço
[[]] -> Moradores


l[[4]][[3]]

library(purrr)
pluck(l, 4, 3)
pluck(l, "uma_string")


seq_along(c(100, 200, 300))
#> [1] 1 2 3


# Fase 1
soma_tres <- function(num) {
  num + 3
}
map_dbl(1:5, soma_tres)

# Fase 2
map_dbl(1:5, function(num) {
  num + 3
})

# Fase 3
map_dbl(1:5, function(num) { num + 3 })

# Fase 4
map_dbl(1:5, function(num) num + 3)

# Fase 5
map_dbl(1:5, \(num) num + 3)

# Fase 6 (pq eu sei oq acontece no 7)
map_dbl(1:5, \(.x) .x + 3)

# Fase 7 (só dentro do tidyverse)
map_dbl(1:5, ~ .x + 3)

# ~ stringr::str_c(.y, " | ", .x)
# \(x, y) stringr::str_c(y, " | ", x)

stringr::str_split(c("a|a|a", "b|a|a", "c|a|a"), "\\|")


