#' Crea un workbook de Excel con varias hojas, cada una conteniendo tablas formateadas
#'
#' Esta función genera un archivo Excel en el que cada hoja contiene un conjunto de tablas formateadas.
#' Cada elemento de la lista principal (\code{list_list_tablas}) corresponde a una hoja distinta.
#' Dentro de cada hoja se escribe un título principal y se exporta cada tabla (data.frame o tibble)
#' usando la función \code{crear_Excel_hoja_Tablas}. Además, se ajusta el formato (por ejemplo, fuente, colores, estilos)
#' y se puede optar por exportar el workbook a un archivo Excel.
#'
#' @param list_list_tablas Lista de listas. Cada elemento de esta lista debe ser, a su vez, una lista de data.frames o tibbles
#'   que se escribirán en una hoja separada. Si algún elemento es un data.frame, se convertirá en una lista para asegurar la consistencia.
#' @param titulos_principales Vector de caracteres. Títulos principales para cada hoja. Si es \code{NULL}, se asignan títulos por defecto.
#' @param titulos_tablas Lista o vector. Títulos para las tablas de cada hoja. Cada elemento de \code{titulos_tablas} se corresponde
#'   con el conjunto de tablas de la hoja respectiva.
#' @param nombres_hojas Vector de caracteres. Nombres de las hojas. Si es \code{NULL}, se asignan nombres por defecto (por ejemplo, "Hoja 1", "Hoja 2", ...).
#' @param hoja Número. Valor por defecto para referenciar la primera hoja. No afecta el nombre de las hojas creadas.
#' @param hay_var_grupo Lógico. Indica si se utilizó una variable de agrupación en la generación de las tablas.
#'   Este parámetro se pasa a las funciones de formateo.
#'
#' @param formatear_tabla Lógico. Si es \code{TRUE}, se formatearán los datos (por ejemplo, redondeo, formato de porcentajes)
#'   antes de escribirlos en Excel. Por defecto es \code{TRUE}.
#' @param estilo_tabla Carácter. Estilo de la tabla en Excel. Por defecto es \code{"TableStyleLight1"}.
#'
#' @param fuente Carácter. Nombre de la fuente a utilizar en los textos. Por defecto es \code{"Calibri"}.
#' @param titulo_principal_tamanyo Número. Tamaño de fuente para el título principal. Por defecto es 14.
#' @param titulo_principal_colorFuente Carácter. Color (en hexadecimal) para el título principal. Por defecto es \code{"#00b2a9"}.
#' @param titulo_tabla_colorFuente Carácter. Color (en hexadecimal) para el título de cada tabla. Por defecto es \code{"#00b2a9"}.
#' @param titulo_tabla_tamanyo Número. Tamaño de fuente para el título de cada tabla. Por defecto es 12.
#' @param tabla_conFiltro Lógico. Si es \code{TRUE}, se aplicarán filtros a las tablas en Excel. Por defecto es \code{TRUE}.
#'
#' @param nombre_archivo Carácter. Nombre del archivo Excel de salida (sin extensión). Si es \code{NULL}, se asigna un nombre por defecto.
#' @param exportar Lógico. Si es \code{TRUE}, se guarda el workbook en un archivo Excel. Por defecto es \code{TRUE}.
#' @param sobreescribir_archivo Lógico. Si es \code{TRUE}, se sobrescribe el archivo existente. Por defecto es \code{TRUE}.
#' @param workbook Objeto workbook de \code{openxlsx}. Si es \code{NULL}, se crea un nuevo workbook.
#'
#' @return Devuelve un objeto workbook de \code{openxlsx} con todas las hojas y tablas agregadas.
#'
#' @details La función revisa cada elemento de \code{list_list_tablas} para asegurar que sea una lista de tablas.
#' Para cada hoja se crea un nuevo worksheet con el nombre especificado en \code{nombres_hojas} y se escribe un título principal,
#' seguido de las tablas formateadas (usando \code{crear_Excel_hoja_Tablas}). Si \code{exportar} es \code{TRUE}, se guarda el workbook en un archivo Excel.
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
#'  temp_agruados_num1 <-  generar_descriptivos_agrupados(temp, vars_grupo = 'grupo', return_df = T)
#'  crear_Excel_variasHojas(temp_agruados_num1, exportar = T)
#' }
#'
#' @importFrom openxlsx createWorkbook addWorksheet saveWorkbook
#' @export
crear_Excel_variasHojas <- function(
    list_list_tablas,
    titulos_principales = NULL,#"DESCRIPTIVOS UNIVARIADOS",
    titulos_tablas = NULL,
    nombres_hojas = NULL,
    hoja = 1,
    hay_var_grupo = NULL,
    #formatear: redondear valores y ajustarlo a formato para Excel
    formatear_tabla = TRUE,
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
    exportar = TRUE,
    sobreescribir_archivo = TRUE,

    workbook = NULL


) {

  for (i in 1:length(list_list_tablas)) {
    # hago este ajuste para cuando exporta las numericas en 1 solo tibble,
    # para poder tener una lista y que funcionen bien los [[]]

    if( is.data.frame(list_list_tablas[[i]]) ) list_list_tablas[[i]] <- list(list_list_tablas[[i]])
    else next

  }

  titulos_principales <- if( is.null(titulos_principales) ) paste0('TÍTULO PRINCIPAL ', 1:length(list_list_tablas))

  nombres_hojas <- if( is.null(nombres_hojas) ) paste0('Hoja ', 1:length(list_list_tablas))

  workbook <- createWorkbook()

  for (i in seq_len(length(list_list_tablas))) {

    # Creando el workbook y la hoja
    addWorksheet(workbook, sheetName = nombres_hojas[i], gridLines = FALSE)


    crear_Excel_hoja_Tablas(
      workbook         = workbook,
      list_tablas      = list_list_tablas[[i]],
      titulo_principal = titulos_principales[i],#"DESCRIPTIVOS UNIVARIADOS",
      titulos_tablas   = titulos_tablas[[i]],
      nombre_hoja      = nombres_hojas[i],
      hoja             = i,
      hay_var_grupo = NULL,
      #formatear: redondear valores y ajustarlo a formato para Excel
      formatear_tabla = TRUE,
      # estilo tabla
      estilo_tabla = estilo_tabla,
      # formatos
      fuente  = fuente,
      titulo_principal_tamanyo = titulo_principal_tamanyo,
      titulo_principal_colorFuente   = titulo_principal_colorFuente,
      titulo_tabla_colorFuente = titulo_tabla_colorFuente,
      titulo_tabla_tamanyo = titulo_tabla_tamanyo,
      tabla_conFiltro = tabla_conFiltro,

      # exportar
      nombre_archivo = nombre_archivo,
      exportar = FALSE,
      sobreescribir_archivo = sobreescribir_archivo
    )
  }

  if (exportar) {
    nombre_archivo <- if(is.null(nombre_archivo)) 'Excel_analisisDescriptivo_temp'
    saveWorkbook(workbook, paste0(nombre_archivo, ".xlsx"), overwrite = sobreescribir_archivo)
  }
  workbook
}
