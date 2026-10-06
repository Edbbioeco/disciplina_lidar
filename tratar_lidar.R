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

## Números de pontos ----

lidar_df |> nrow()

## Estatísticas ----

lidar_df |>
  dplyr::summarise(dplyr::across(

    .cols = dplyr::where(is.numeric),
    .fns = list(Média = mean,
                Desvio = sd,
                Máximo = max,
                Mínimo = min)

    ))

## Variação dos valores de altura ----

lidar@data$Z |> range()

## Filtrar os rasters ----

lidar_clas <- lidar |>
  lidR::filter_poi(Z |> dplyr::between(10, 50))

lidar_clas

lidar_clas |> lidR::plot(color = "RGB")

## Normalizar ----

### Criar DTM ----

dtm <- lidar |>
  lidR::classify_ground(algorithm = lidR::csf()) |>
  lidR::filter_ground() |>
  lidR::rasterize_terrain(res = 1, algorithm = lidR::tin())

dtm

ggplot() +
  tidyterra::geom_spatraster(data = dtm) +
  scale_fill_viridis_c()

### Normalizar ----

las_norm <- lidar |>
  lidR::normalize_height(algorithm = dtm)

las_norm

## Perfil de elevação ----

### Transformar o LiDAr em um raster RGB ----

lidar_rast <- lidar |>
  lidR::pixel_metrics(func = ~list(R = mean(R),
                                   G = mean(G),
                                   B = mean(B)),
                      res = 0.5) |>
  terra::app(fun = \(x) x / 256) |>
  terra::clamp(lower = 0, upper = 255)

lidar_rast <- lidar_rast / 256

lidar_rast

ggplot() +
  tidyterra::geom_spatraster_rgb(data = lidar_rast)
