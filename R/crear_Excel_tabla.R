#' Crea una hoja de Excel con una tabla formateada
#'
#' Esta función escribe una tabla (data.frame o tibble) en un objeto workbook de Excel, aplicando formato a los datos (por ejemplo, porcentajes y números) según el tipo de tabla (numérica o categórica). Además, permite agregar un título principal y un título para la tabla, y opcionalmente exporta el workbook a un archivo Excel.
#'
#' @param tabla Data.frame o tibble. La tabla de datos a exportar.
#' @param workbook Objeto workbook de \code{openxlsx}. Si es \code{NULL}, se crea un nuevo workbook.
#' @param nombre_hoja Nombre de la hoja. Si es \code{NULL}, se asigna un nombre basado en el valor de \code{hoja} (por ejemplo, "Hoja 1").
#' @param hoja Número o nombre de la hoja en la que se escribirá la información. Por defecto es 1.
#'
#' @param formatear_tabla Lógico. Si es \code{TRUE}, se formatea la tabla utilizando \code{formatear_tabla_numerica} o \code{formatear_tabla_categorica} según el atributo \code{tipo_tabla} de \code{tabla}. Por defecto es \code{TRUE}.
#' @param tipo_tabla Carácter. Indica si la tabla es 'numerica' o 'categorica'. Si es \code{NULL}, se intenta detectar automáticamente a partir del atributo \code{tipo_tabla} de \code{tabla}.
#' @param hay_var_grupo Lógico. Indica si se ha utilizado una variable de agrupación. Si es \code{NULL}, se intenta detectar automáticamente a partir del atributo \code{vars_grupo} de \code{tabla}.
#'
#' @param titulo_tabla Carácter. Título de la tabla. Si es \code{NULL}, se asigna el valor "Tabla 1".
#' @param numero_fila Número. La fila de inicio donde se escribirá la tabla. Por defecto es 4.
#' @param titulo_principal Carácter. Título principal que se escribirá en la parte superior de la hoja. Si es \code{NULL}, no se escribe título principal.
#'
#' @param fuente Carácter. Nombre de la fuente a utilizar para los textos. Por defecto es "Calibri".
#' @param titulo_tabla_colorFuente Carácter. Color (en hexadecimal) para el texto del título de la tabla. Por defecto es "#00b2a9".
#' @param titulo_tabla_tamanyo Número. Tamaño de fuente para el título de la tabla. Por defecto es 12.
#' @param estilo_tabla Carácter. Estilo de tabla de Excel. Por defecto es "TableStyleLight1".
#' @param tabla_conFiltro Lógico. Si es \code{TRUE}, la tabla en Excel tendrá filtros. Por defecto es \code{TRUE}.
#'
#' @param titulo_principal_tamanyo Número. Tamaño de fuente para el título principal. Por defecto es 14.
#' @param titulo_principal_colorFuente Carácter. Color (en hexadecimal) para el título principal. Por defecto es "#00b2a9".
#'
#' @param nombre_archivo Carácter. Nombre del archivo Excel de salida (sin extensión). Si es \code{NULL}, se asigna "Tabla_analisisDescriptivo_temp".
#' @param exportar Lógico. Si es \code{TRUE}, se guarda el workbook en un archivo Excel. Por defecto es \code{TRUE}.
#' @param sobreescribir_archivo Lógico. Si es \code{TRUE}, se sobrescribe el archivo de salida en caso de existir. Por defecto es \code{TRUE}.
#'
#' @return Devuelve el objeto workbook con la hoja y la tabla agregada.
#'
#' @details La función valida que \code{tabla} sea un data.frame o tibble. Si se solicita formatear la tabla, se determina el tipo (numérica o categórica) a partir de los atributos \code{tipo_tabla} y \code{vars_grupo}. Se crea (o utiliza) un objeto workbook, se agrega una hoja y se escribe en ella el título principal (si se especifica), el título de la tabla y la tabla formateada. Si \code{exportar} es \code{TRUE}, el workbook se guarda en un archivo Excel.
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
#'    'w'=rlnorm(32))
#'  temp_num <- generar_descriptivo_numerico( datos = temp, var_numerica = 'mpg' )
#'  crear_Excel_tabla(temp_num, exportar = T)
#' }
#' @importFrom openxlsx createWorkbook addWorksheet createStyle writeData addStyle writeDataTable saveWorkbook
#'
#' @export

crear_Excel_tabla <- function(
    tabla,
    workbook = NULL,
    nombre_hoja = NULL,
    hoja = 1,

    # formatea porcentajes y numeros
    formatear_tabla = FALSE,
    tipo_tabla = NULL,
    hay_var_grupo = NULL,

    # titulos y ubicacion
    titulo_tabla = NULL,
    numero_fila  = NULL,
    titulo_principal = NULL,

    # formatos
    fuente  = 'Calibri',
    titulo_tabla_colorFuente = "#00b2a9",
    titulo_tabla_tamanyo = 12,
    estilo_tabla = "TableStyleLight1",
    tabla_conFiltro = T,

    titulo_principal_tamanyo = 14,
    titulo_principal_colorFuente   = "#00b2a9",

    # exportar
    nombre_archivo = NULL,
    exportar = FALSE,
    sobreescribir_archivo = TRUE

){

  if( !is.data.frame(tabla) ) stop("tabla debe ser un data.frame o tibble")

  ## ajustar tabla
  if( formatear_tabla ){

    if( is.null(tipo_tabla) ){
      tipo_tabla <- attr(tabla, 'tipo_tabla')
      if( is.null(tipo_tabla) ) stop("Tipo_tabla no detectado automáticamente. Se debe especificar 'numerica' o 'categorica'")
    }
    if( is.null(hay_var_grupo) ){
      hay_var_grupo <- attr(tabla, 'vars_grupo')
      if( is.null(hay_var_grupo) ) stop("hay_var_grupo no detectado automáticamente. Se debe especificar TRUE o FALSE si se ha utilizado una variabla para agrupar como vars_grupo")
    }

    tabla <- switch (tipo_tabla,
                     numerica   =  formatear_tabla_numerica(tabla),
                     categorica =  formatear_tabla_categorica(tabla, hay_var_grupo = hay_var_grupo)
    )
  }

  if (is.null(workbook)) {
    nombre_hoja <- if( is.null(nombre_hoja) ) paste0('Hoja ', hoja)
    # Creando el workbook y la hoja
    workbook <- createWorkbook()
    addWorksheet(workbook, sheetName = nombre_hoja, gridLines = FALSE)
  }


  estilo_titulo_tabla <- createStyle(
    fontName = fuente,
    fontSize = titulo_tabla_tamanyo,
    fontColour = titulo_tabla_colorFuente
  )

  if( !is.null(titulo_principal) ){

    titulo_principal <- 'TÍTULO PRINCIPAL 1'
    estilo_titulo_principal <- createStyle(
      fontName = fuente,
      fontSize = titulo_principal_tamanyo,
      fontColour = titulo_principal_colorFuente
    )
    # Escribir el título principal en la hoja
    writeData(workbook, sheet = hoja, x = titulo_principal, startRow = 1, startCol = 1)
    addStyle(wb = workbook, sheet = hoja, rows = 1, cols = 1, style = estilo_titulo_principal)
  }

  # Escribir el título de cada tabla
  if( is.null(titulo_tabla) ) titulo_tabla <- 'Tabla 1'
  if( is.null(numero_fila) ) numero_fila <- 4

  writeData(workbook, sheet = hoja, x = titulo_tabla,
            startRow = numero_fila-1, startCol = 1)
  addStyle(wb = workbook, sheet = hoja, rows = numero_fila-1,
           cols = 1, style = estilo_titulo_tabla
  )

  # Escribir la tabla
  writeDataTable(
    workbook, sheet = hoja, x = tabla,
    startRow = numero_fila,
    startCol = 2, tableStyle = estilo_tabla, withFilter = tabla_conFiltro
  )

  if (exportar) {
    nombre_archivo <- if(is.null(nombre_archivo)) 'Tabla_analisisDescriptivo_temp'
    saveWorkbook(workbook, paste0(nombre_archivo, ".xlsx"), overwrite = sobreescribir_archivo)
  }

  workbook
}
