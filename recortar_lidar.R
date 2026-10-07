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

## Filtrar raster e transformar em shapefile ----

dtm_70 <- (dtm > 70) |>
  tidyterra::filter(Z == TRUE) |>
  terra::as.polygons() |>
  sf::st_as_sf(crs = lidar |> sf::st_crs()) |>
  sf::st_cast("POLYGON") |>
  dplyr::slice(5)

dtm_70

ggplot() +
  tidyterra::geom_spatraster(data = dtm) +
  geom_sf(data = dtm_70,
          color = "red", fill = "transparent") +
  scale_fill_viridis_c()

## Recortar LiDAR ----

lidar_crop <- lidar_norm |>
  lidR::clip_roi(dtm_70)

lidar_crop

## Exportar LiDAR ----

lidar_crop |> lidR::writeLAS("lidar_crop.las")
