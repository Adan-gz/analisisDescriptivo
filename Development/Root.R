
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
