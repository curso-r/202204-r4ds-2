cat("Ele disse \"escapar\"")

cat("\"")
cat("\.")
cat("\\.")

# \" e \'
# \n
# \t

cat("ele disse\nenter")

"\\."
"\\$"
"\\^"
"\\{"

library(stringr)

texto <- "O meu RG é 89.123.123-7 e meu nome é Caio"
str_extract(texto, "[0-9]{2}\\.[0-9]{3}\\.[0-9]{3}-[0-9]")

texto <- "O meu RG é 89.123123-7 e meu nome é Caio"
str_extract(texto, "[0-9\\-\\.]+")

texto <- "O meu RG é 89.123123-7 e meu nome é Caio e tenho 26 anos"
str_extract_all(texto, "[0-9\\-\\.]+")

texto <- "O meu RG é 89.123123-7 e meu nome é Caio e tenho 26 anos"
str_extract_all(texto, "[0-9\\-\\.]{9,12}")

"colocar uma \""
'colocar uma "barra"'
'this "word"\'s meaning'

r"(this "word"'s meaning)"
r"(\.)"

str_replace("Bom dia.", "\\.", "!")
str_replace("Bom dia.", r"(\.)", "!")
