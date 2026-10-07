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

