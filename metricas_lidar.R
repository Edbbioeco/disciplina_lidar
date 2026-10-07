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

## Normalizar ----

lidar_norm <- lidar |>
  lidR::normalize_height(algorithm = dtm) |>
  lidR::filter_poi(!Z < 0)

lidar_norm

# Métricas ----

## Criar polígono ----

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

poli <- trajeto$finished

poli

leaflet::leaflet() |>
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
                       fillOpacity = 0) |>
  leaflet::addPolygons(data = poli,
                       color = "gold",
                       fillOpacity = 0)

## Recortar ----

lidar_cort <- lidar_norm |>
  lidR::clip_roi(poli |>
                   sf::st_transform(lidar_norm |> sf::st_crs()))

lidar_cort

## Calcular métricas ----

metrica <- lidar_cort |>
  lidR::pixel_metrics(~list(
    MaxH = max(Z),
    MeanH = mean(Z),
    SD_H = sd(Z),
    P95 = quantile(Z, 0.95),
    GapFrac = (sum(Z < 2) / length(Z)),
    Dens_Herb = (sum(Z >= 0 & Z < 2) / length(Z)) * 100,
    Dens_Sub  = (sum(Z >= 2 & Z < 5) / length(Z)) * 100,
    Dens_Mid  = (sum(Z >= 5 & Z < 10) / length(Z)) * 100,
    Dens_Copa = (sum(Z >= 10) / length(Z)) * 100),
    res = 10)

metrica

## Visualizar ----

nomes_metricas <- metrica |> terra::names()

nomes_metricas

purrr::map(
  nomes_metricas,
  \(nome){

    ggplot() +
      tidyterra::geom_spatraster(data = metrica[[nome]]) +
      scale_fill_viridis_c(na.value = "transparent") +
      facet_wrap(~lyr) +
      labs(fill = nome) +
      theme_bw() +
      theme(text = element_text(color = "black"),
            legend.text = element_text(color = "black"),
            legend.title = element_text(color = "black", size = 15),
            strip.text = element_text(color = "black", size = 25))

    },
  .progress = TRUE) |>
  patchwork::wrap_plots() +
  ggview::canvas(height = 10, width = 12)

ggsave(filename = "mapa_metricas.png",
       height = 10, width = 12)
