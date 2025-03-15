#' Genera una hoja en un workbook Excel con tablas y títulos formateados
#'
#' Esta función escribe en una hoja de un workbook Excel un título principal, títulos para cada tabla
#' y las tablas propiamente dichas, aplicando estilos personalizados a los títulos.
#'
#' @param list_tablas Lista de data.frames que se exportarán.
#' @param titulo_principal Título principal que se escribirá en la fila 1.
#' @param titulos_tablas Vector con los títulos de cada tabla.
#' @param nombre_hoja (opcional) Nombre de la hoja en el workbook; si es \code{NULL} se genera a partir del número de hoja.
#' @param hoja Número de hoja en el workbook.
#' @param estilo_tabla Nombre del estilo de tabla predefinido de Excel (por ejemplo, "TableStyleLight1").
#' @param nombre_archivo Nombre base del archivo Excel a exportar (sin extensión).
#' @param exportar Lógico; si es \code{TRUE} guarda el archivo Excel.
#' @param sobreescribir_archivo Lógico; si es \code{TRUE} sobrescribe el archivo si ya existe.
#' @param tabla_conFiltro Lógico; si es \code{TRUE} la tabla se crea con filtros.
#' @param workbook (opcional) Objeto workbook de \code{openxlsx}; si es \code{NULL} se crea uno nuevo.
#' @param fuente Fuente a utilizar para los títulos.
#' @param titulo_principal_tamanyo Tamaño de fuente para el título principal.
#' @param titulo_principal_colorFuente Color de la fuente para el título principal.
#' @param titulo_tabla_colorFuente Color de la fuente para los títulos de las tablas.
#' @param titulo_tabla_tamanyo Tamaño de fuente para los títulos de las tablas.
#'
#' @return Un objeto \code{workbook} de \code{openxlsx} con la hoja y tablas agregadas.
#'
#' @examples
#' list_temp <- list(head(mtcars,5),head(mtcars,5),head(mtcars,5))
#'
#' generar_hojaExcel(
#'  list_temp,
#'  titulo_principal = "DESCRIPTIVOS UNIVARIADOS",
#'  titulos_tablas = letters[1:length(list_temp)],
#'  nombre_archivo = 'prueba',
#'  exportar = TRUE
#'  )
#'
#' @import openxlsx
#' @importFrom purrr map_dbl
#' @import tibble
#' @export
crear_hojaExcel <- function(
    list_tablas,
    titulo_principal = "DESCRIPTIVOS UNIVARIADOS",
    titulos_tablas,
    nombre_hoja = NULL,
    hoja = 1,
    estilo_tabla = "TableStyleLight1",
    nombre_archivo,
    exportar = FALSE,
    sobreescribir_archivo = TRUE,
    tabla_conFiltro = TRUE,
    workbook = NULL,
    fuente = "Calibri",
    titulo_principal_tamanyo = 14,
    titulo_principal_colorFuente = "#00b2a9",
    titulo_tabla_colorFuente = "#00b2a9",
    titulo_tabla_tamanyo = 12
) {
  estilo_titulo_principal <- createStyle(
    fontName = fuente,
    fontSize = titulo_principal_tamanyo,
    fontColour = titulo_principal_colorFuente
  )
  estilo_titulo_tabla <- createStyle(
    fontName = fuente,
    fontSize = titulo_tabla_tamanyo,
    fontColour = titulo_tabla_colorFuente
  )
  # Obtengo la posición de cada tabla
  tablas_posicion <- asignar_filas_tablas(list_tablas)

  if (is.null(workbook)) {
    # Creando el workbook y la hoja
    workbook <- createWorkbook()
    nombre_hoja <- if (is.null(nombre_hoja)) paste0("Hoja_", hoja)
    addWorksheet(workbook, sheetName = nombre_hoja, gridLines = FALSE)
  }

  # Escribir el título principal en la hoja
  writeData(workbook, sheet = hoja, x = titulo_principal, startRow = 1, startCol = 1)
  addStyle(wb = workbook, sheet = hoja, rows = 1, cols = 1, style = estilo_titulo_principal)

  for (i in seq_len(length(list_tablas))) {
    # Escribir el título de cada tabla
    writeData(workbook, sheet = hoja, x = titulos_tablas[i],
              startRow = tablas_posicion$tituloFila[i], startCol = 1)
    addStyle(wb = workbook, sheet = hoja, rows = tablas_posicion$tituloFila[i],
             cols = 1, style = estilo_titulo_tabla)

    # Escribir la tabla
    writeDataTable(
      workbook, sheet = hoja, x = list_tablas[[i]],
      startRow = tablas_posicion$primeraFila[i],
      startCol = 2, tableStyle = estilo_tabla, withFilter = tabla_conFiltro
    )
  }

  if (exportar) {
    saveWorkbook(workbook, paste0(nombre_archivo, ".xlsx"), overwrite = sobreescribir_archivo)
  }

  workbook
}
