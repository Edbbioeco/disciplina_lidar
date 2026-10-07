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
