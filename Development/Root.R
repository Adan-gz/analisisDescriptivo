
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

c('dplyr','stringr','tidyr','purrr','scales')

# Archivos R funciones ----------------------------------------------------

funciones <- paste0(
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
for ( f in funciones) {
  use_r( f )
}
