# Pacotes ----

library(lidR)

library(tidyverse)

library(terra)

library(tidyterra)

library(ggview)

# Dados ----

## LiDAR ----

### Importar ----

lidar <- lidR::readLAS("NP_RGB.las")

### Visualizar ----

lidar

lidar |> lidR::plot(color = "RGB")

# Tratar LiDAR ----

## Criar DTM ----

dtm <- lidar |>
  lidR::classify_ground(algorithm = lidR::csf()) |>
  lidR::filter_ground() |>
  lidR::rasterize_terrain(res = 1, algorithm = lidR::tin())

dtm

ggplot() +
  tidyterra::geom_spatraster(data = dtm) +
  scale_fill_viridis_c()

### Normalizar ----

lidar_norm <- lidar |>
  lidR::normalize_height(algorithm = dtm) |>
  lidR::filter_poi(!Z < 0)

lidar_norm
