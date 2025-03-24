#' Generar descriptivos para variables numéricas
#'
#' Calcula estadísticas descriptivas para múltiples variables numéricas de un data frame o tibble,
#' permitiendo la especificación de variables de agrupación y de peso. Si no se especifican las variables
#' numéricas y \code{selecc_vars_auto} es \code{TRUE}, se seleccionan automáticamente todas las variables numéricas.
#'
#' @param datos Data frame o tibble que contiene las variables numéricas a analizar.
#' @param vars_numericas Vector de nombres de variables numéricas a analizar. Si es \code{NULL} y \code{selecc_vars_auto} es
#'   \code{TRUE}, se seleccionan automáticamente todas las variables numéricas.
#' @param vars_grupo Vector de nombres de variables para agrupar. Por defecto es \code{NULL} (sin agrupamiento).
#' @param var_peso Nombre (carácter) de la variable de peso. Si es \code{NULL} (por defecto), se calculan estadísticas sin ponderación.
#' @param nivel_confianza Nivel de confianza para el cálculo de intervalos (por defecto \code{0.95}).
#' @param estrategia_valoresPerdidos_grupo Estrategia para el manejo de valores faltantes en la variable de agrupación. Se debe elegir
#'   \code{"E"} para eliminar o \code{"A"} para agrupar (NS/NC). Por defecto es \code{c("A", "E")}, de modo que se selecciona
#'  @param unificar_1tabla Lógico. Si es \code{TRUE}, se retorna un único data frame combinando todos los descriptivos; de lo contrario,
#'   se retorna una lista de data frames.
#' @param selecc_vars_auto Lógico. Si es \code{TRUE} y \code{vars_numericas} es \code{NULL}, se seleccionan automáticamente las variables numéricas.
#'
#' @return Lista de data frames, uno por cada variable numérica analizada, o un data frame único si \code{unificar_1tabla} es \code{TRUE}.
#'
#' @details
#' La función:
#' \enumerate{
#'   \item Selecciona las variables numéricas a analizar (si no se especifican y \code{selecc_vars_auto} es \code{TRUE}).
#'   \item Aplica \code{generar_descriptivo_numerico} a cada variable.
#'   \item Retorna una lista con los resultados o, si se solicita, un data frame combinado con todos los descriptivos.
#' }
#'
#' @examples
#' \dontrun{
#'   # Ejemplo sin agrupación y sin pesos:
#'   resultados <- generar_descriptivos_numericos(
#'                   datos = mtcars,
#'                   nivel_confianza = 0.95,
#'                   selecc_vars_auto = TRUE
#'                 )
#'
#'   # Ejemplo combinando resultados en un único data frame:
#'   resumen_df <- generar_descriptivos_numericos(
#'                   datos = mtcars,
#'                   vars_numericas = c("mpg", "hp"),
#'                   unificar_1tabla = TRUE
#'                 )
#' }
#'
#' @importFrom dplyr select_if bind_rows
#' @importFrom purrr map set_names
#' @importFrom magrittr %>%
#'
#' @export
generar_descriptivos_numericos <- function(
    datos,
    vars_numericas = NULL,
    vars_grupo = NULL,
    var_peso = NULL,
    nivel_confianza = 0.95,
    unificar_1tabla = FALSE,
    selecc_vars_auto = TRUE,
    estrategia_valoresPerdidos_grupo = c('A','E')
) {
  # Seleccionar automáticamente las variables numéricas si no se especifican
  if (is.null(vars_numericas) && selecc_vars_auto) {
    vars_numericas <- datos %>% select_if(is.numeric) %>% select(-any_of(c(vars_grupo,var_peso)) ) %>% colnames()
  }
  # Aplicar la función para cada variable numérica y guardar resultados en una lista
  resultados <- purrr::map(
    vars_numericas,
    \(var_num) generar_descriptivo_numerico(
      datos = datos,
      var_numerica = var_num,
      vars_grupo = vars_grupo,
      var_peso = var_peso,
      nivel_confianza = nivel_confianza,
      estrategia_valoresPerdidos_grupo = estrategia_valoresPerdidos_grupo
    )
  ) %>% purrr::set_names(vars_numericas)

  # Si se solicita retornar un data frame único, combinar los resultados
  if (unificar_1tabla) {
    return(bind_rows(resultados))
  }
  resultados
}
