
library(devtools)
library(usethis)
# create_package()
use_git()
use_mit_license()

use_r("function_example.R")
# rename_files()
document()
load_all() # carga las funcone pero no en el environment global
exists("function_example", where = globalenv(), inherits = FALSE)
check()
install()

use_package(
  c(
    'dplyr','purrr','tidyr'
    )
)

use_github() # tengo que conectarlo
use_readme_rmd() # tengo que hacerlo
use_devtools() # genra un .Rprofile


use_build_ignore("Development") # para ignorar la carpeta

#conectar con github
# https://happygitwithr.com/new-github-first.html

# https://github.com/Adan-gz/analisisDescriptivo.git #HTTPS SSH Github


# R Packages --------------------------------------------------------------

c('dplyr','stringr','tidyr','purrr','scales','skimr')

# Archivos R funciones ----------------------------------------------------

#auxiliares
funciones_auxiliares <- paste0(
  c(
    'add_titleNote',
    'percent',
    'number',
    'convert_p_num',
    'sd_pond',
    'ci_margenError_pWilson',
    'margenError_num'
  ),
  '.R'
)

funciones_excel <- paste0(
  c('preparar_tabla_excel',
    'concatenar_tablas_excel'),
  '.R'
)

funciones_categoricas <- c(
  'generar_descriptivo_categorico.R',
  'generar_descriptivos_categoricos.R'
)

funciones_num <- c(
  'generar_descriptivo_numerico.R',
  'generar_descriptivo_numericos.R'
)

funciones_globales <- c('generar_descriptivos_agrupados.R',
                        'generar_descriptivos_univariados.R'
                        )

for ( f in funciones_globales) {
  use_r( f )
}
use_r('generar_hojaExcel_descriptivos.R')
