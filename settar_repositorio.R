# Pacotes ----

library(usethis)

library(gert)

# Iniciando git ----

usethis::use_git()

# Primeiro commit ----

gert::git_add(files = ".gitignore")

gert::git_commit(message = "gitignore")

# Criar repositório ----

usethis::use_github()

# Criar README ----

usethis::use_readme_md()
