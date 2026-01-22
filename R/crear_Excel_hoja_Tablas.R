#' Crea una hoja de Excel con múltiples tablas formateadas
#'
#' Esta función escribe en una única hoja de un objeto workbook de Excel múltiples tablas formateadas.
#' Se escribe un título principal en la parte superior de la hoja y, para cada tabla de la lista, se calcula la posición de inicio (utilizando la función \code{asignar_filas_tablas}) para evitar solapamientos.
#' Cada tabla se escribe aplicando un título propio y, opcionalmente, se pueden aplicar filtros y estilos.
#'
#' @param tablas Lista de data.frames o tibbles. Cada elemento de la lista se escribirá como una tabla en la hoja.
#' @param titulo_principal Carácter. Título principal que se escribirá en la parte superior de la hoja. Si es \code{NULL}, se asigna un título por defecto basado en el valor de \code{hoja}.
#' @param titulos_tablas Vector de caracteres. Títulos para cada tabla. Si es \code{NULL}, se asignan títulos por defecto.
#' @param nombre_hoja Carácter. Nombre de la hoja. Si es \code{NULL}, se asigna un nombre basado en el valor de \code{hoja}.
#' @param hoja Número o nombre de la hoja en la que se escribirá la información. Por defecto es 1.
#' @param hay_var_grupo Lógico. Indica si se utilizó una variable de agrupación para generar las tablas.
#'
#' @param formatear_tabla Lógico. Si es \code{TRUE}, se formatea cada tabla (por ejemplo, redondeo de valores y conversión a porcentajes) antes de escribirla. Por defecto es \code{TRUE}.
#' @param estilo_tabla Carácter. Estilo de tabla de Excel a aplicar. Por defecto es \code{"TableStyleLight1"}.
#'
#' @param fuente Carácter. Nombre de la fuente a utilizar para los textos. Por defecto es \code{"Calibri"}.
#' @param titulo_principal_tamanyo Número. Tamaño de fuente para el título principal. Por defecto es 14.
#' @param titulo_principal_colorFuente Carácter. Color (en hexadecimal) para el título principal. Por defecto es \code{"#00b2a9"}.
#' @param titulo_tabla_colorFuente Carácter. Color (en hexadecimal) para el título de cada tabla. Por defecto es \code{"#00b2a9"}.
#' @param titulo_tabla_tamanyo Número. Tamaño de fuente para el título de cada tabla. Por defecto es 12.
#' @param tabla_conFiltro Lógico. Si es \code{TRUE}, se aplicarán filtros a las tablas de Excel. Por defecto es \code{TRUE}.
#'
#' @param nombre_archivo Carácter. Nombre del archivo Excel de salida (sin extensión). Si es \code{NULL}, se asigna "HojadeTablas_analisisDescriptivo_temp".
#' @param exportar Lógico. Si es \code{TRUE}, se guarda el workbook en un archivo Excel. Por defecto es \code{TRUE}.
#' @param sobreescribir_archivo Lógico. Si es \code{TRUE}, se sobrescribe el archivo de salida en caso de existir. Por defecto es \code{TRUE}.
#' @param workbook Objeto workbook de \code{openxlsx}. Si es \code{NULL}, se crea un nuevo workbook.
#' @param filas_tablas_asignadas Data.frame con la posición de cada tabla. Por defecto \code{NULL}, es de uso interno.
#' @return Devuelve un objeto workbook de \code{openxlsx} con la hoja y las tablas agregadas.
#'
#' @details La función valida que \code{tablas} sea una lista y, en caso de que se proporcionen nombres para las tablas (a través de \code{names(tablas)}), se incorporan al título de cada tabla.
#' Se utiliza la función \code{asignar_filas_tablas} para calcular la posición de cada tabla en la hoja y se escribe un título principal en la parte superior.
#' Cada tabla se escribe utilizando la función \code{crear_Excel_tabla}.
#'
#' @examples
#' \dontrun{
#'   library(dplyr)
#'   temp <- mtcars %>%
#'    mutate(
#'    'cyl'=as.character(cyl),
#'    'carb'=factor(carb),
#'    'gear' = factor(gear),
#'    'grupo' = sample(c('A','B'),nrow(.),T),
#'    'w'=rlnorm(32)
#'    )
#'  temp_numericas <- generar_descriptivos_numericos(temp)
#'  crear_Excel_hoja_Tablas(temp_numericas, exportar = T)
#' }
#'
#'
#' @importFrom openxlsx createWorkbook addWorksheet createStyle writeData addStyle writeDataTable saveWorkbook
#'
#' @export
crear_Excel_hoja_Tablas <- function(
    tablas,
    titulo_principal = NULL,#"DESCRIPTIVOS UNIVARIADOS",
    fila_titulo_principal = 1,
    titulos_tablas = NULL,
    nombre_hoja = NULL,
    hoja = 1,
    hay_var_grupo = NULL,
    #formatear: redondear valores y ajustarlo a formato para Excel
    formatear_tabla = FALSE,
    # estilo tabla
    estilo_tabla = "TableStyleLight1",
    # formatos
    fuente  = 'Calibri',
    titulo_principal_tamanyo = 14,
    titulo_principal_colorFuente   = "#00b2a9",
    titulo_tabla_colorFuente = "#00b2a9",
    titulo_tabla_tamanyo = 12,
    tabla_conFiltro = TRUE,

    # exportar
    nombre_archivo = NULL,
    exportar = FALSE,
    sobreescribir_archivo = TRUE,

    workbook = NULL,
    filas_tablas_asignadas = NULL

) {

  if( !is.list(tablas) ){
    stop("El objeto tablas debe ser una lista. Si tienes una sola tabla puedes utilizar 'crear_Excel_tabla'")
  }
  # tablas <- if(is.data.frame(tablas)) list(tablas)

  ## ajustar
  # cat(titulos_tablas,'\n')
  # titulos_tablas <- if( is.null(titulos_tablas) ){ titulos_tablas <- paste0('Tabla ', 1:length(tablas)) }
  # cat(titulos_tablas,'\n')
  # titulos_tablas <- if(!is.null(names(tablas)))paste0(titulos_tablas,'. ', names(tablas))



  # genero workbook si no hay
  if (is.null(workbook)) {
    # nombre de la hoja
    nombre_hoja <- if( is.null(nombre_hoja) ) paste0('Hoja ', hoja)
    # Creando el workbook y la hoja
    workbook <- createWorkbook()
    addWorksheet(workbook, sheetName = nombre_hoja, gridLines = FALSE)
  }

  # Obtengo la posición de cada tabla
  if ( is.null(filas_tablas_asignadas)  ){
    tablas_posicion <- asignar_filas_tablas(tablas)
  } else {
    tablas_posicion <- filas_tablas_asignadas
  }

  # Escribir el título principal en la hoja
  if( is.null(titulo_principal) ) titulo_principal <-  paste0('TÍTULO PRINCIPAL ', hoja)

  estilo_titulo_principal <- createStyle(
    fontName = fuente,
    fontSize = titulo_principal_tamanyo,
    fontColour = titulo_principal_colorFuente
  )
  writeData(workbook, sheet = hoja, x = titulo_principal, startRow = fila_titulo_principal, startCol = 1)
  addStyle(wb = workbook, sheet = hoja, rows = fila_titulo_principal, cols = 1, style = estilo_titulo_principal)

  ## GENERAMOS LAS HOJA
  estilo_titulo_tabla <- createStyle(
    fontName = fuente,
    fontSize = titulo_tabla_tamanyo,
    fontColour = titulo_tabla_colorFuente
  )

  for (i in seq_len(length(tablas))) {

    crear_Excel_tabla(
      tabla    = tablas[[i]],
      workbook = workbook,
      hoja = hoja,
      # formatea porcentajes y numeros
      formatear_tabla = formatear_tabla,
      tipo_tabla = NULL,
      hay_var_grupo = hay_var_grupo,

      # titulos y ubicacion
      titulo_tabla = titulos_tablas,
      numero_fila  = tablas_posicion$primeraFila[i],

      # formatos
      fuente  = 'Calibri',
      titulo_tabla_colorFuente = titulo_tabla_colorFuente,
      titulo_tabla_tamanyo = titulo_tabla_tamanyo,
      estilo_tabla = estilo_tabla,
      tabla_conFiltro = T,

      # exportar
      exportar = FALSE
    )

  }

  if (exportar) {
    nombre_archivo <- if(is.null(nombre_archivo)) 'HojadeTablas_analisisDescriptivo_temp'
    saveWorkbook(workbook, paste0(nombre_archivo, ".xlsx"), overwrite = sobreescribir_archivo)
  }

  workbook
}
