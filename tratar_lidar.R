# Pacotes ----

library(lidR)

library(sf)

library(tidyverse)

library(terra)

library(tidyterra)

library(leaflet)

library(leaflet.extras)

library(leafem)

# Dados ----

## LiDAR ----

### Importar ----

lidar <- lidR::readLAS("NP_RGB.las")

### Visualizar ----

lidar

lidar |> lidR::plot(color = "RGB")

## Shapefiles de pontos ----

### Criar shapefile de pontos ----

lidar_pontos <- lidar |>
  sf::st_bbox() |>
  sf::st_as_sfc() |>
  sf::st_as_sf() |>
  sf::st_sample(size = 25)

### Visualizar ----

lidar_pontos

ggplot() +
  geom_sf(data = lidar_pontos)

# Propriedades do LiDAR ----

## Criar o data frame ----

lidar_df <- lidar@data |>
  tibble::tibble()

## Visualizar ----

lidar_df

lidar_df |> dplyr::glimpse()
