# Pacotes ----

library(tidyverse)

library(lidR)

library(terra)

library(tiyterra)

library(patchwork)

library(ggview)

library(flextable)

# Dados ----

## Importar ----

lidar <- lidR::readLAS("NP_RGB.las")

## Visualizar ----

lidar

lidar |> lidR::plot(color = "RGB")

# Normalizar ----

## Criar DTM ----

dtm <- lidar |>
  lidR::classify_ground(algorithm = lidR::csf()) |>
  lidR::filter_ground() |>
  lidR::rasterize_terrain(res = 1, algorithm = lidR::tin())

dtm

ggplot() +
  tidyterra::geom_spatraster(data = dtm) +
  scale_fill_viridis_c()
