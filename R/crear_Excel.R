#' Crea un workbook de Excel con varias hojas, cada una conteniendo tablas formateadas
#'
#' Esta función genera un archivo Excel en el que cada hoja contiene un conjunto de tablas formateadas.
#' Cada elemento de la lista principal (\code{list_list_tablas}) corresponde a una hoja distinta.
#' Dentro de cada hoja se escribe un título principal y se exporta cada tabla (data.frame o tibble)
#' usando la función \code{crear_Excel_hoja_Tablas}. Además, se ajusta el formato (por ejemplo, fuente, colores, estilos)
#' y se puede optar por exportar el workbook a un archivo Excel.
#'
#' @param list_list_tablas Lista de listas. Cada elemento de esta lista debe ser, a su vez, una lista de data.frames o tibbles
#'   que se escribirán en una hoja separada. Si algún elemento es un data.frame, se convertirá en una lista para asegurar la consistencia. Si únicamente
#'   se quiere exportar una tabla (1 data.frame), utilizar \code{crear_Excel_tabla}.
#' @param unificar_misma_hoja Unificar listas en 1 misma hoja. Por ejemplo, que las tablas de descriptivos numéricos y categóricos, que por defecto
#' se recogen en 2 listas distintas, aparezcan en la misma hoja. Por defecto \(code){TRUE}.
#' @param titulos_principales Vector de caracteres. Títulos principales para cada hoja. Si es \code{NULL}, se asignan títulos por defecto.
#' @param titulos_tablas Lista o vector. Títulos para las tablas de cada hoja. Cada elemento de \code{titulos_tablas} se corresponde
#'   con el conjunto de tablas de la hoja respectiva.
#' @param nombres_hojas Vector de caracteres. Nombres de las hojas. Si es \code{NULL}, se asignan nombres por defecto (por ejemplo, "Hoja 1", "Hoja 2", ...).
#' @param hoja Número. Valor por defecto para referenciar la primera hoja. No afecta el nombre de las hojas creadas.
#' @param hay_var_grupo Lógico. Indica si se utilizó una variable de agrupación en la generación de las tablas. Este parámetro se pasa a las funciones de formateo. No utilizar salvo Error.
#'
#' @param formatear_tabla Lógico. Si es \code{TRUE}, se formatearán los datos (por ejemplo, redondeo, formato de porcentajes)
#'   antes de escribirlos en Excel. Por defecto es \code{TRUE}. Si las tablas que se introducen no provienen de las funciones \code{generar_descriptivos_*} pasarlo a \code{FALSE}.
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
#' @return Devuelve un objeto workbook de \code{openxlsx} con todas las hojas y tablas agregadas. Exporta un archivo Excel.
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
#'  crear_Excel(temp_agruados_num1, exportar = T)
#'
#'  ## Es posible generar los univariados y luego los agrupados:
#'  library(dplyr)
#'  temp <- mtcars %>%
#'    mutate('cyl'=as.character(cyl),
#'           'carb'=factor(carb),
#'           'gear' = factor(gear),
#'           'grupo' = sample(c('A','B'),nrow(.),T),
#'           'w'=rlnorm(32))
#'
#'  desc_univariados <- generar_descriptivos_univariados(temp)
#'  desc_agrupados <- generar_descriptivos_agrupados(temp, vars_grupo = 'grupo', var_peso = 'w')
#'
#'  workbook <- crear_Excel(
#'    desc_univariados,
#'    nombres_hojas = 'UNIVARIADOS',
#'    unificar_misma_hoja = T,
#'    exportar = F
#'  )
#'
#'  workbook <- crear_Excel(
#'    desc_agrupados,
#'    workbook = workbook,
#'    nombres_hojas = 'AGRUPADO',
#'    unificar_misma_hoja = T,
#'    exportar = T
#'  )#'
#' }
#'
#' @importFrom openxlsx createWorkbook addWorksheet saveWorkbook
#' @export
crear_Excel <- function(
    list_list_tablas,# output de generar_descriptivos_univariados o generar_descriptivos_agrupados
    unificar_misma_hoja = TRUE,
    titulos_principales = NULL,#"DESCRIPTIVOS UNIVARIADOS",
    titulos_tablas = NULL,
    nombres_hojas = NULL,
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
    exportar = FALSE,
    sobreescribir_archivo = TRUE,

    workbook = NULL


) {

  if( is.data.frame(list_list_tablas) ) list_list_tablas <- list(list_list_tablas)

  for (i in 1:length(list_list_tablas)) {
    # hago este ajuste para cuando exporta las numericas en 1 solo tibble,
    # para poder tener una lista y que funcionen bien los [[]]

    if( is.data.frame(list_list_tablas[[i]]) ) list_list_tablas[[i]] <- list(list_list_tablas[[i]])
    else next

  }
  # genero workbook si no existe
  if( is.null(workbook) ){
    workbook_salida  <- createWorkbook()
    hojas_existentes <- 0
  } else{
    workbook_salida <- workbook
    hojas_existentes <- if(is.null(workbook)) 0 else length( workbook$sheet_names )
  }

  if( is.null(titulos_principales) ) titulos_principales <- paste0('TÍTULO PRINCIPAL ', (hojas_existentes + 1:length(list_list_tablas)))

  if( is.null(nombres_hojas) ) nombres_hojas <-  paste0('Hoja ', (hojas_existentes + 1:length(list_list_tablas)) )

  # print(unificar_misma_hoja)
  if( unificar_misma_hoja ){ # genero las hojas
    # creo la hoja y tambien ubico las tablas
    addWorksheet(workbook_salida, sheetName = nombres_hojas[1], gridLines = FALSE)
    # generar las posiciones
    # genero una lista de tibbles con las posiciones de lsa tablas
    filas_tablas_asignadas <- vector('list',length = length(list_list_tablas))
    primera_fila.i <- 4 # primera fila de la tabla, se va ajustando
    # ubico tambien la fila del titulo principa
    fila_titulo_principal  <- rep(NA,length = length(list_list_tablas))
    for (i in seq_len(length(list_list_tablas))) {
      # Creando el workbook y la hoja
      filas_tablas_asignadas.i    <- asignar_filas_tablas(list_list_tablas[[i]], primeraFila = primera_fila.i )
      filas_tablas_asignadas[[i]] <- filas_tablas_asignadas.i
      # la primera tabla de la lista i se ubica 4 filas despues de la ultima de la tabla i-1
      primera_fila.i <- filas_tablas_asignadas.i$primeraFila[nrow(filas_tablas_asignadas.i)] +
        filas_tablas_asignadas.i$Nfilas[nrow(filas_tablas_asignadas.i)] + 4
      fila_titulo_principal[i] <- filas_tablas_asignadas.i$primeraFila[1] - 2
    }


  } else {
    # si no unifico, genero varias hojas
    for (i in seq_len(length(list_list_tablas))) {
      # Creando el workbook y la hoja
      addWorksheet(workbook_salida, sheetName = nombres_hojas[i], gridLines = FALSE)
      filas_tablas_asignadas <- NULL
    }

  }

  # gEnero el Excel
  for (i in seq_len(length(list_list_tablas))) {
    # ajustes en funcion de si es misma hoha o no
    if( unificar_misma_hoja ){
      hoja <- hojas_existentes+1 # el parametro de hoja es constante
      fila_titulo_principal.i  <- fila_titulo_principal[i]
      filas_tablas_asignadas.i <- filas_tablas_asignadas[[i]]

    } else {
      hoja <- hojas_existentes+i
      fila_titulo_principal.i <- 1
      filas_tablas_asignadas.i <- NULL
    }

    crear_Excel_hoja_Tablas(
      workbook         = workbook_salida,

      filas_tablas_asignadas = filas_tablas_asignadas.i,
      fila_titulo_principal  = fila_titulo_principal.i,

      list_tablas      = list_list_tablas[[i]],
      titulo_principal = titulos_principales[i],#"DESCRIPTIVOS UNIVARIADOS",
      titulos_tablas   = titulos_tablas[[i]],
      nombre_hoja      = nombres_hojas.i,
      hoja             = hoja,
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
    if(is.null(nombre_archivo))  nombre_archivo <- 'Excel_analisisDescriptivo_temp'
    saveWorkbook(workbook_salida, file = paste0(nombre_archivo, ".xlsx"), overwrite = sobreescribir_archivo)
  }
  workbook_salida
}


