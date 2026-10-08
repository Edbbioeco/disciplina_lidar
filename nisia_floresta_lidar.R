# Pacotes ----

library(readxl)

library(tidyverse)

library(geosphere)

library(sf)

library(lidR)

library(tidyterra)

library(terra)

library(patchwork)

library(ggview)

# Dados

## Coordenadas ----

### Importar ----

coord <- readxl::read_xlsx("Parcelas_NISIA.xlsx")

### Visualizar ----

coord

coord |> dplyr::glimpse()
