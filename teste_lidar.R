# Pacotes ----

library(lidR)

library(lidRmetrics)

# Dados ----

## Dados de LiDAR ----

### Importar ----

lidar <- system.file("extdata", "Megaplot.laz", package = "lidR") |>
  lidR::readLAS()

### Visualizar ----

lidar

lidar |> lidR::plot()

## Pontos ----

### Importar ----

pontos <- base::system.file("extdata", "efi_plot.shp", package = "lidR") |>
  sf::st_read() |>
  sf::st_transform(crs = 4674)

### Visualizar ----

pontos

ggplot() +
  geom_sf(data = pontos)
