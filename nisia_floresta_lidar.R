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

## Transormar em shapeile ----

parcelas <- coord |>
  tidyr::drop_na() |>
  dplyr::select(c(5, 12:13)) |>
  sf::st_as_sf(coords = c(2:3),
               crs = 4674) |>
  dplyr::group_by(parcela) |>
  dplyr::summarise(do_union = FALSE) |>
  sf::st_cast("LINESTRING")

ggplot() +
  geom_sf(data = parcelas)

## Exportar o shapefile ----

parcelas |> sf::st_write("parcelas_nisia.gpkg")
