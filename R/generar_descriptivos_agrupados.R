#' Generar descriptivos agrupados
#'
#' Calcula descriptivos univariados para variables categóricas y numéricas, agrupando los datos por las variables de grupo.
#' Si no se especifican las variables a analizar, se seleccionan automáticamente según su clase.
#'
#' @param datos Data frame o tibble con los datos a analizar.
#' @param vars_categoricas Vector de nombres de variables categóricas. Si es \code{NULL} y \code{selecc_vars_auto} es \code{TRUE},
#'   se seleccionan automáticamente las variables de tipo carácter o factor.
#' @param vars_numericas Vector de nombres de variables numéricas. Si es \code{NULL} y \code{selecc_vars_auto} es \code{TRUE},
#'   se seleccionan automáticamente las variables numéricas.
#' @param vars_grupo Vector de nombres de variables de agrupación.
#' @param var_peso Nombre de la variable de peso, si se desea ponderar los cálculos. Por defecto \code{NULL}.
#' @param nivel_confianza Nivel de confianza para los intervalos. Por defecto \code{0.95}.
#' @param selecc_vars_auto Lógico. Si es \code{TRUE}, se seleccionan automáticamente las variables si no se especifican. Por defecto \code{TRUE}.
#' @param pivot Lógico. Si es \code{TRUE}, se pivota la salida de variables categóricas a formato ancho (solo para tibbles agrupados). Por defecto \code{TRUE}.
#' @param variable_pivot Vector de caracteres que indica la variable a utilizar para pivotear: \code{"var_grupo"} o \code{"var_categorica"}. Por defecto \code{c("var_grupo", "var_categorica")}.
#' @param estrategia_valoresPerdidos Estrategia para el manejo de valores faltantes en variables categóricas: \code{"E"} (eliminar) o \code{"A"} (agrupar en "NS/NC"). Por defecto \code{c("E", "A")}.
#' @param digits Valor de precisión para formatear los descriptivos numéricos. Por defecto \code{0.1}.
#' @param return_df Lógico. Si es \code{TRUE}, se retorna un único data frame combinando los descriptivos numéricos; si es \code{FALSE},
#'   se retorna una lista. Por defecto \code{FALSE}.
#'
#' @return Una lista con dos elementos:
#'   \itemize{
#'     \item \code{Numericas}: Descriptivos para variables numéricas agrupadas.
#'     \item \code{Categoricas}: Descriptivos para variables categóricas agrupadas.
#'   }
#'
#' @details
#' La función aplica internamente \code{generar_descriptivos_categoricos} y \code{generar_descriptivos_numericos},
#' considerando las variables de agrupación especificadas.
#'
#' @examples
#' \dontrun{
#'   resultados <- generar_descriptivos_agrupados(
#'                   datos = mtcars,
#'                   vars_categoricas = c("cyl"),
#'                   vars_numericas = c("mpg", "hp"),
#'                   vars_grupo = c("gear"),
#'                   nivel_confianza = 0.95,
#'                   pivot = TRUE,
#'                   variable_pivot = "var_grupo",
#'                   estrategia_valoresPerdidos = "E",
#'                   digits = 0.1,
#'                   return_df = FALSE
#'                 )
#' }
#'
#' @importFrom dplyr select_if
#' @importFrom magrittr %>%
#'
#' @export
generar_descriptivos_agrupados <- function(
    datos,
    vars_categoricas = NULL,
    vars_numericas = NULL,
    vars_grupo = NULL,
    var_peso = NULL,
    nivel_confianza = 0.95,
    selecc_vars_auto = TRUE,
    pivot = TRUE,
    variable_pivot = c("var_grupo", "var_categorica"),
    estrategia_valoresPerdidos = c("E", "A"),
    digits = 0.1,
    return_df = FALSE,
    simplificar_output = TRUE
) {
  # Inicializar resultados para descriptivos numéricos y categóricos
  descriptivos_num <- NULL
  descriptivos_cat <- NULL

  # Seleccionar automáticamente variables numéricas y categóricas si no se especifican
  if (is.null(vars_numericas) && selecc_vars_auto) {
    vars_numericas <- datos %>% select_if(is.numeric) %>% select(-any_of(c(vars_grupo,var_peso)) ) %>% colnames()
  }
  if (is.null(vars_categoricas) && selecc_vars_auto) {
    vars_categoricas <- datos %>% select_if(~ is.character(.) || is.factor(.)) %>% select(-any_of(c(vars_grupo,var_peso)) ) %>% colnames()
  }

  # Convertir variables dummies a numericas
  ## POR IMPLEMENTAR

  # Calcular descriptivos para variables categóricas agrupadas (si existen)
  if (length(vars_categoricas) > 0) {
    descriptivos_cat <- generar_descriptivos_categoricos(
      datos = datos,
      vars_categoricas = vars_categoricas,
      vars_grupo = vars_grupo,
      var_peso = var_peso,
      pivot = pivot,
      variable_pivot = variable_pivot,
      nivel_confianza = nivel_confianza,
      estrategia_valoresPerdidos = estrategia_valoresPerdidos,
      simplificar_output = simplificar_output
    )
    message("Descriptivos agrupados categóricos generados")
  }

  # Calcular descriptivos para variables numéricas agrupadas (si existen)
  if (length(vars_numericas) > 0) {

    descriptivos_num <- generar_descriptivos_numericos(
      datos = datos,
      vars_numericas = vars_numericas,
      vars_grupo = vars_grupo,
      var_peso = var_peso,
      digits = digits,
      nivel_confianza = nivel_confianza,
      return_df = return_df
    )
    message("Descriptivos agrupados numéricos generados")
  }

  # Crear lista de salida
  salida <- list(
    Numericas = descriptivos_num,
    Categoricas = descriptivos_cat
  )

  # Guardar atributos informativos
  attr(salida, "vars_grupo") <- TRUE
  attr(salida, "peso") <- !is.null(var_peso)

  salida
}
