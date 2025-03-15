#' Genera un workbook Excel con múltiples hojas, cada una con tablas y títulos formateados
#'
#' Esta función crea un workbook Excel en el que cada hoja contiene un título principal,
#' títulos para cada tabla y las tablas formateadas. Para cada hoja se utiliza la función \code{generar_hojaExcel}.
#'
#' @param list_list_tablas Lista de listas; cada sublista contiene los data.frames a exportar en una hoja.
#' @param titulos_principales Vector de títulos principales para cada hoja. Si es \code{NULL} se asignan valores por defecto.
#' @param titulos_tablas Lista de vectores, donde cada vector contiene los títulos de las tablas correspondientes a cada hoja.
#' @param nombres_hojas Vector con los nombres de las hojas. Si es \code{NULL} se asignan nombres por defecto.
#' @param estilo_tabla Nombre del estilo de tabla predefinido de Excel (por ejemplo, "TableStyleLight1").
#' @param tabla_conFiltro Lógico; si es \code{TRUE} las tablas se crean con filtros.
#' @param fuente Fuente a utilizar para los títulos.
#' @param titulo_principal_tamanyo Tamaño de fuente para el título principal.
#' @param titulo_principal_colorFuente Color de la fuente para el título principal.
#' @param titulo_tabla_colorFuente Color de la fuente para los títulos de las tablas.
#' @param titulo_tabla_tamanyo Tamaño de fuente para los títulos de las tablas.
#' @param nombre_archivo Nombre base del archivo Excel a exportar (sin extensión). Si es \code{NULL} se asigna un nombre por defecto.
#' @param exportar Lógico; si es \code{TRUE} guarda el archivo Excel.
#' @param sobreescribir_archivo Lógico; si es \code{TRUE} sobrescribe el archivo si ya existe.
#' @param formatear Cuando el input \code{list_list_tablas} proviene de utilizar \code{generar_descriptivos_agrupados}
#' se formatea los porcentajes y los números. Por defecto \code{TRUE}. Este parámetro está pendiente de mejoras.
#'
#' @return Un objeto \code{workbook} de \code{openxlsx} con todas las hojas y tablas agregadas.
#'
#' @examples
#'
#' library(dplyr)
#' temp <- mtcars %>%
#'  mutate('cyl'=as.character(cyl),
#'         'carb'=factor(carb),
#'             'gear' = factor(gear),
#'             'w'=rlnorm(32))
#' temp_biv_simple <- generar_descriptivos_agrupados(
#'  datos = temp,
#'  vars_grupo = "cyl",
#'  vars_numericas = "mpg",
#'  vars_categoricas = "vs",
#'  var_peso = "w"
#'  )
#'
#' crear_Excel(temp_biv_simple, exportar = T, formatear = T)
#'#'
#' ## Otro ejemplo
#' list_temp <- list(head(mtcars,5),head(mtcars,5),head(mtcars,5))
#' list_list_temp <- list(list_temp,list_temp)
#'
#' workoob_temp <- crear_Excel(
#'  list_list_temp, # lista de listas
#'  exportar = T
#'  )
#'
#' @import openxlsx
#' @importFrom purrr map
#' @export
crear_Excel <- function(

  list_list_tablas, # lista de listas

  # titulos
  titulos_principales = NULL, # vector de titulos
  titulos_tablas = NULL, # lista de 2 vectores
  nombres_hojas = NULL, # # vector de nombres

  # estilo tabla
  estilo_tabla = "TableStyleLight1",
  tabla_conFiltro = TRUE,

  # permitir formatear titulos
  fuente  = 'Calibri',
  titulo_principal_tamanyo = 14,
  titulo_principal_colorFuente   = "#00b2a9",
  titulo_tabla_colorFuente = "#00b2a9",
  titulo_tabla_tamanyo = 12,

  ## exportar
  nombre_archivo = NULL,
  exportar = FALSE,
  sobreescribir_archivo = TRUE,

  ## formatear si viene de generar_descriptivos_agrupados
  formatear = T
){

  if( formatear ){
    list_list_tablas <- generar_hoja_excel_descriptivos( list_list_tablas, concatenar = F, añadir_titulos = F  )

  }

  n_hojas <- length(list_list_tablas)

  titulos_principales <- if( is.null(titulos_principales) ) paste0('Titulo Principal ', 1:n_hojas)
  nombres_hojas <- if( is.null(nombres_hojas) ) paste0('Hoja_', 1:n_hojas)
  if( is.null(titulos_tablas) ){

    titulos_tablas <- purrr::map(
      1:n_hojas,
      \(i) paste0('Tabla ', 1:length( list_list_tablas[[i]] ) )
    )

  }
  # Creating workbook
  workbook <- createWorkbook()

  for ( i in 1:n_hojas ) {

    # Create sheet
    addWorksheet(workbook, sheetName = nombres_hojas[i], gridLines = F)

    workbook <- crear_hojaExcel(
      workbook         = workbook,
      list_tablas      = list_list_tablas[[i]],
      titulo_principal = titulos_principales[i],
      titulos_tablas   = titulos_tablas[[i]],
      # nombre_hoja      = nombres_hojas[i],
      hoja             = i,
      tabla_conFiltro  = tabla_conFiltro,

      fuente  = fuente,
      titulo_principal_tamanyo = titulo_principal_tamanyo,
      titulo_principal_colorFuente   = titulo_principal_colorFuente,
      titulo_tabla_colorFuente = titulo_tabla_colorFuente,
      titulo_tabla_tamanyo = titulo_tabla_tamanyo
    )
  }

  if( exportar ){

    nombre_archivo <- if(is.null(nombre_archivo)) 'analisisDescriptivo_temp'
    openxlsx::saveWorkbook(workbook, paste0(nombre_archivo,".xlsx"),overwrite = sobreescribir_archivo)

  }

  workbook
}
