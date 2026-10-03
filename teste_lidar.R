# Pacotes ----

library(lidR)

library(lidRmetrics)

# Dados ----

## Dados de LiDAR ----

### Importar ----

lidar <- system.file("extdata", "Megaplot.laz", package = "lidR") |>
  lidR::readLAS()
