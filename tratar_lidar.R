# Pacotes ----

library(lidR)

library(sf)

library(tidyverse)

library(terra)

library(tidyterra)

library(leaflet)

library(leaflet.extras)

library(leafem)

library(mapedit)

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

lidar_rast

ggplot() +
  tidyterra::geom_spatraster_rgb(data = lidar_rast)

### Criar shapefile de trajeto ----

mapa <- leaflet::leaflet() |>
  leaflet::addProviderTiles(providers$Esri.WorldImagery) |>
  leaflet.extras::addDrawToolbar(
    targetGroup = "Draw",
    polylineOptions = leaflet.extras::drawPolylineOptions(),
    polygonOptions = leaflet.extras::drawPolygonOptions(),
    circleOptions = leaflet.extras::drawCircleOptions(),
    rectangleOptions = leaflet.extras::drawRectangleOptions(),
    markerOptions = leaflet.extras::drawMarkerOptions(),
    circleMarkerOptions = leaflet.extras::drawCircleMarkerOptions(),
    editOptions = leaflet.extras::editToolbarOptions()) |>
  leafem::addMouseCoordinates() |>
  leaflet::addPolygons(data = lidar |>
                         sf::st_bbox() |>
                         sf::st_as_sfc() |>
                         sf::st_as_sf() |>
                         sf::st_transform(crs = 4326),
                       color = "red",
                       fillOpacity = 0)

mapa

trajeto <- mapedit::editMap(mapa)

traj <- trajeto$finished

traj

ggplot() +
  tidyterra::geom_spatraster_rgb(data = lidar_rast) +
  geom_sf(data = traj, color = "red")

### Criar buffer do trajeto ----

traj_buf <- traj |>
  sf::st_buffer(dist = 1)

traj_buf

ggplot() +
  tidyterra::geom_spatraster_rgb(data = lidar_rast) +
  geom_sf(data = traj_buf, color = "red")
