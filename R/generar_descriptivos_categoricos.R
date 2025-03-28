#' Generar descriptivos para variables categóricas
#'
#' Aplica la función \code{generar_descriptivo_categorico} a múltiples variables categóricas de un data frame,
#' permitiendo la selección automática de variables si no se especifica ninguna. Además, elimina de forma automática
#' aquellas variables categóricas que coincidan con las de agrupación.
#'
#' @param datos Data frame o tibble con las variables a analizar.
#' @param vars_categoricas Vector de nombres de variables categóricas. Si es \code{NULL} y \code{selecc_vars_auto} es
#'   \code{TRUE}, se seleccionan automáticamente las variables de tipo carácter o factor.
#' @param vars_grupo Vector de nombres de variables de agrupación.
#' @param var_peso Nombre (carácter) de la variable de pesos. Por defecto es \code{NULL}.
#' @param pivot Lógico. Si es \code{TRUE} (por defecto), se pivota la tabla resultante en cada análisis individual.
#' @param variable_pivot Vector de caracteres que indica la variable a utilizar para pivotear:
#'   \code{"var_grupo"} o \code{"var_categorica"}. Por defecto es \code{c("var_grupo", "var_categorica")}.
#' @param nivel_confianza Nivel de confianza para los intervalos. Por defecto es \code{0.95}.
#' @param estrategia_valoresPerdidos Estrategia para manejar faltantes: \code{"E"} (eliminar) o \code{"A"} (agrupar en "NS/NC").
#'   Por defecto es \code{c("A", "E")}, lo que selecciona \code{"A"}.
#' @param selecc_vars_auto Lógico. Si es \code{TRUE} y \code{vars_categoricas} es \code{NULL}, se seleccionan
#'   automáticamente las variables de tipo carácter o factor. Por defecto es \code{TRUE}.
#' @param simplificar_output Reducir la cantidad de información que se exporta cuando se utiliza \code{vars_grupo}.
#'
#' @return Lista de data frames, uno por cada variable categórica analizada, nombrados según dicha variable.
#'
#' @details La función:
#' \enumerate{
#'   \item Selecciona las variables categóricas a analizar (si no se especifican y \code{selecc_vars_auto} es \code{TRUE}).
#'   \item Elimina de \code{vars_categoricas} aquellas variables que coincidan con las de agrupación.
#'   \item Itera sobre cada variable categórica, aplicando \code{generar_descriptivo_categorico} y retorna una lista
#'      con los resultados.
#' }
#'
#' @examples
#' \dontrun{
#'   # Supongamos que 'datos' contiene variables categóricas y de agrupación
#'   resultados <- generar_descriptivos_categoricos(
#'                   datos = datos,
#'                   vars_categoricas = c("sexo", "estado_civil"),
#'                   vars_grupo = c("region"),
#'                   var_peso = "peso",
#'                   pivot = TRUE,
#'                   variable_pivot = "var_grupo",
#'                   nivel_confianza = 0.95,
#'                   estrategia_valoresPerdidos = "E",
#'                   selecc_vars_auto = FALSE
#'                 )
#' }
#'
#' @importFrom dplyr select_if
#' @importFrom magrittr %>%
#' @importFrom purrr map set_names
#'
#' @export
generar_descriptivos_categoricos <- function(
    datos,
    vars_categoricas = NULL,
    vars_grupo = NULL,
    var_peso = NULL,
    pivot = TRUE,
    variable_pivot = c("var_grupo", "var_categorica"),
    nivel_confianza = 0.95,
    estrategia_valoresPerdidos = c("A", "E"),
    selecc_vars_auto = TRUE,
    simplificar_output = TRUE
) {
  # Seleccionar automáticamente variables categóricas si no se especifica ninguna
  if (is.null(vars_categoricas) && selecc_vars_auto) {
    vars_categoricas <- datos %>%
      select_if(\(x) is.character(x) || is.factor(x)) %>%
      select(-any_of(c(vars_grupo,var_peso)) ) %>%
      colnames()
  }

  # Si alguna variable categórica coincide con las de agrupación, eliminarla de vars_categoricas
  if (any(vars_categoricas %in% vars_grupo)) {
    warning("Alguna variable de agrupación coincide con una variable categórica. Se eliminará de vars_categoricas.")
    vars_categoricas <- vars_categoricas[!vars_categoricas %in% vars_grupo]
  }

  # Aplicar la función individual a cada variable categórica
  resultados <- purrr::map(
    vars_categoricas,
    \(var_cat) generar_descriptivo_categorico(
      datos = datos,
      var_categorica = var_cat,
      vars_grupo = vars_grupo,
      var_peso = var_peso,
      pivot = pivot,
      variable_pivot = variable_pivot,
      nivel_confianza = nivel_confianza,
      estrategia_valoresPerdidos = estrategia_valoresPerdidos,
      simplificar_output = simplificar_output
    )
  )

  # Asignar nombres a la lista resultante
  resultados %>% purrr::set_names(vars_categoricas)
}
