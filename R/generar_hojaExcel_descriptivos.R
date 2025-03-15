#' Formatear descriptivos para hoja de Excel
#'
#' Esta función formatea una lista de descriptivos univariados (generada con \code{generar_descriptivos_univariados})
#' para exportarla a una hoja de Excel. Aplica un formateo numérico a las variables numéricas y un formateo porcentual a
#' las variables categóricas, agregando además filas de encabezado a cada sección. Finalmente, concatena todas las tablas
#' en un único data frame.
#'
#' @param tablas_descriptivos Lista nombrada con los descriptivos univariados, que debe contener los elementos \code{Numericas} y \code{Categoricas}.
#' @param precision_num Precisión para formatear los números. Por defecto es \code{0.1}.
#' @param escala_num Factor de escala para los números. Por defecto es \code{1}.
#' @param sufijo_num Sufijo a añadir a los números. Por defecto es cadena vacía.
#' @param prefijo_num Prefijo a añadir a los números. Por defecto es cadena vacía.
#' @param estilo_positivo_num Estilo para números positivos. Valores aceptados: \code{"none"}, \code{"plus"} o \code{"space"}. Por defecto es \code{"none"}.
#' @param precision_fac Precisión para formatear los porcentajes. Por defecto es \code{0.1}.
#' @param escala_fac Factor de escala para los porcentajes. Por defecto es \code{100}.
#' @param sufijo_fac Sufijo a añadir a los porcentajes. Por defecto es \code{"\%"}.
#' @param estilo_positivo_fac Estilo para porcentajes positivos. Valores aceptados: \code{"none"}, \code{"plus"} o \code{"space"}. Por defecto es \code{"none"}.
#' @param separador_decimal Carácter a utilizar como separador decimal. Por defecto es \code{","}.
#' @param separador_miles Carácter a utilizar como separador de miles. Por defecto es \code{"."}.
#'
#' @return Data frame listo para exportar a Excel, con los descriptivos formateados y concatenados.
#'
#' @details
#' La función realiza lo siguiente:
#' \enumerate{
#'   \item Extrae los descriptivos numéricos y categóricos de la lista.
#'   \item Aplica un formateo numérico a los valores numéricos utilizando \code{scales::number}, excepto en las columnas
#'         \code{N} y \code{Missing}.
#'   \item Aplica un formateo porcentual a los valores de variables categóricas utilizando \code{scales::percent}. En función
#'         de si los datos están agrupados, se seleccionan diferentes columnas.
#'   \item Agrega una fila de encabezado a cada sección (numérica y categórica).
#'   \item Concatena todas las tablas utilizando la función \code{concatenar_tibbles}.
#' }
#'
#' @examples
#' \dontrun{
#'   # Suponiendo que 'mis_descriptivos' es la lista resultante de generar_descriptivos_univariados()
#'   hoja_excel <- generar_hoja_excel_descriptivos(
#'                   descriptivos_univariados = mis_descriptivos,
#'                   precision_num = 0.1,
#'                   escala_num = 1,
#'                   sufijo_num = "",
#'                   prefijo_num = "",
#'                   estilo_positivo_num = "none",
#'                   precision_fac = 0.1,
#'                   escala_fac = 100,
#'                   sufijo_fac = "%",
#'                   estilo_positivo_fac = "none",
#'                   separador_decimal = ",",
#'                   separador_miles = "."
#'                 )
#' }
#'
#' @importFrom dplyr mutate across where ends_with contains
#' @importFrom magrittr %>%
#' @importFrom purrr map map_df
#' @importFrom tibble tibble
#'
#' @export
generar_hoja_excel_descriptivos <- function(
    tablas_descriptivos,
    # tablas_descriptivos_numericos = NULL,
    # tablas_descriptivos_categoricos = NULL,
    precision_num = 0.1,
    escala_num  = 1,
    sufijo_num = "",
    prefijo_num = "",
    estilo_positivo_num = "none",
    precision_fac = 0.1,
    escala_fac = 100,
    sufijo_fac = "%",
    estilo_positivo_fac = "none",
    separador_decimal = ",",
    separador_miles = "."
) {

  # univ_num <- if (!is.null(tablas_descriptivos)) tablas_descriptivos$Numericas else tablas_descriptivos_numericos
  # univ_cat <- if (!is.null(tablas_descriptivos)) tablas_descriptivos$Categoricas else tablas_descriptivos_categoricos


  # Extraer descriptivos numéricos y categóricos de la lista
  univ_num <- tablas_descriptivos$Numericas
  univ_cat <- tablas_descriptivos$Categoricas

  # Determinar si los descriptivos categóricos están agrupados
  is_agrupado <- !is.null(attr(tablas_descriptivos, "vars_grupo"))

  # Si existen descriptivos numéricos, aplicar formateo a cada data frame
  if (!is.null(univ_num)) {
    univ_num <- purrr::map_df(
      univ_num,
      function(.df) {
        .df %>%
          mutate(
            across(
              c(where(is.numeric), -any_of(c('N', 'Missing', 'p_value'))),
              function(x) {
                scales::number(
                  x,
                  accuracy = precision_num,
                  scale = escala_num,
                  decimal.mark = separador_decimal,
                  big.mark = separador_miles,
                  prefix = prefijo_num,
                  suffix = sufijo_num,
                  style_positive = estilo_positivo_num
                )
              }
            ),
            across(
              any_of('p_value'),
              \(x) scales::number(x,accuracy = .0001,decimal.mark = separador_decimal,big.mark = separador_miles)
            )
          )
      }
    )
    # Agregar encabezado a la sección numérica
    univ_num <- append(
      list(tibble("DESCRIPTIVOS - VARIABLES NUMÉRICAS" = "")),
      list(univ_num)
    )
  }

  # Si existen descriptivos categóricos, aplicar formateo a cada data frame
  if (!is.null(univ_cat)) {
    univ_cat <- purrr::map(
      univ_cat,
      function(.df) {
        if (!is_agrupado) {
          .df %>%
            mutate(
              across(
                p:sd,
                function(x) {
                  scales::percent(
                    x,
                    accuracy = precision_fac,
                    scale = escala_fac,
                    decimal.mark = separador_decimal,
                    big.mark = separador_miles,
                    suffix = sufijo_fac,
                    style_positive = estilo_positivo_fac
                  )
                }
              )
            )
        } else {
          .df %>%
            mutate(
              across(
                c(ends_with("_p"), contains("_p_"), ends_with("_sd")),
                function(x) {
                  scales::percent(
                    x,
                    accuracy = precision_fac,
                    scale = escala_fac,
                    decimal.mark = separador_decimal,
                    big.mark = separador_miles,
                    suffix = sufijo_fac,
                    style_positive = estilo_positivo_fac
                  )
                }
              ),
              across(
                c(Chi2,VCramer),
                function(x){
                  scales::number(
                    x,
                    accuracy = 0.01,
                    scale = escala_num,
                    decimal.mark = separador_decimal,
                    big.mark = separador_miles,
                    prefix = prefijo_num,
                    suffix = sufijo_num,
                    style_positive = estilo_positivo_num
                  )
                }
              ),
              'p_value' = scales::number(p_value,accuracy = .0001,decimal.mark = separador_decimal,big.mark = separador_miles)
            )
        }
      }
    )

    # Asegurar que 'univ_cat' sea una lista y agregar encabezado a la sección categórica
    if (!is.list(univ_cat)) univ_cat <- list(univ_cat)
    univ_cat <- append(
      list(tibble("DESCRIPTIVOS - VARIABLES CATEGÓRICAS" = "")),
      univ_cat
    )
  }

  # Combinar las secciones numérica y categórica
  out <- append(univ_num, univ_cat)

  # Concatenar todas las tablas en un único data frame listo para Excel
  concatenar_tablas_excel(out)
}
