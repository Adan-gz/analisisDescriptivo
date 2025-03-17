#' Generar descriptivos univariados
#'
#' Calcula descriptivos univariados para variables categóricas y numéricas de un data frame o tibble.
#' Si no se especifican las variables, se seleccionan automáticamente según su clase.
#'
#' @param datos Data frame o tibble con los datos a analizar.
#' @param vars_categoricas Vector de nombres de variables categóricas. Si es \code{NULL} y \code{selecc_vars_auto} es \code{TRUE},
#'   se seleccionan automáticamente las variables de tipo carácter o factor.
#' @param vars_numericas Vector de nombres de variables numéricas. Si es \code{NULL} y \code{selecc_vars_auto} es \code{TRUE},
#'   se seleccionan automáticamente las variables numéricas.
#' @param var_peso Nombre de la variable de peso, si se desea ponderar los cálculos. Por defecto \code{NULL}.
#' @param nivel_confianza Nivel de confianza para los intervalos. Por defecto \code{0.95}.
#' @param selecc_vars_auto Lógico. Si es \code{TRUE}, se seleccionan automáticamente las variables si no se especifican. Por defecto \code{TRUE}.
#' @param pivot Lógico. Si es \code{TRUE}, se pivota la salida de variables categóricas a formato ancho (solo si los datos están agrupados). Por defecto \code{TRUE}.
#' @param variable_pivot Vector de caracteres que indica la variable a utilizar para pivotear: \code{"var_grupo"} o \code{"var_categorica"}. Por defecto \code{"var_grupo"}.
#' @param estrategia_valoresPerdidos Estrategia para el manejo de valores faltantes en variables categóricas: \code{"E"} (eliminar) o \code{"A"} (agrupar en "NS/NC"). Por defecto \code{"E")}.
#' @param digits Valor de precisión para formatear los descriptivos numéricos. Por defecto \code{0.1}.
#' @param num_unificar_1tabla Lógico. Si es \code{TRUE}, se retorna un único data frame combinando los descriptivos numéricos; si es \code{FALSE},
#'   se retorna una lista. Por defecto \code{FALSE}. Sólo para las numéricas
#'
#' @return Una lista con dos elementos:
#'   \itemize{
#'     \item \code{Numericas}: Descriptivos para variables numéricas.
#'     \item \code{Categoricas}: Descriptivos para variables categóricas.
#'   }
#'
#' @details
#' La función aplica internamente \code{generar_descriptivos_categoricos} y \code{generar_descriptivos_numericos}.
#'
#' @examples
#' \dontrun{
#'   # Ejemplo con variables especificadas
#'   resultados <- generar_descriptivos_univariados(
#'                   datos = mtcars,
#'                   vars_categoricas = c("cyl", "gear"),
#'                   vars_numericas = c("mpg", "hp"),
#'                   nivel_confianza = 0.95,
#'                   pivot = TRUE,
#'                   variable_pivot = "var_grupo",
#'                   estrategia_valoresPerdidos = "E",
#'                   digits = 0.1,
#'                   num_unificar_1tabla = FALSE
#'                 )
#' }
#'
#' @importFrom dplyr select_if
#' @importFrom purrr map set_names
#' @importFrom magrittr %>%
#'
#' @export
generar_descriptivos_univariados <- function(
    datos,
    vars_categoricas = NULL,
    vars_numericas = NULL,
    var_peso = NULL,
    nivel_confianza = 0.95,
    selecc_vars_auto = TRUE,
    pivot = TRUE,
    variable_pivot = c("var_grupo", "var_categorica"),
    estrategia_valoresPerdidos = c("E", "A"),
    digits = 0.1,
    num_unificar_1tabla = FALSE
) {
  # Inicializar resultados para descriptivos numéricos y categóricos
  descriptivos_num <- NULL
  descriptivos_cat <- NULL

  # Seleccionar automáticamente variables numéricas y categóricas si no se especifican
  if (is.null(vars_numericas) && selecc_vars_auto) {
    vars_numericas <- datos %>% select_if(is.numeric) %>% colnames()
  }
  if (is.null(vars_categoricas) && selecc_vars_auto) {
    vars_categoricas <- datos %>% select_if(~ is.character(.) || is.factor(.)) %>% colnames()
  }

  # Calcular descriptivos para variables categóricas (si existen)
  if (length(vars_categoricas) > 0) {
    descriptivos_cat <- generar_descriptivos_categoricos(
      datos = datos,
      vars_categoricas = vars_categoricas,
      var_peso = var_peso,
      pivot = pivot,
      variable_pivot = variable_pivot,
      nivel_confianza = nivel_confianza,
      estrategia_valoresPerdidos = estrategia_valoresPerdidos
    )
    message("Descriptivos univariados categóricos generados")
  }

  # Calcular descriptivos para variables numéricas (si existen)
  if (length(vars_numericas) > 0) {
    descriptivos_num <- generar_descriptivos_numericos(
      datos = datos,
      vars_numericas = vars_numericas,
      var_peso = var_peso,
      digits = digits,
      nivel_confianza = nivel_confianza,
      unificar_1tabla = num_unificar_1tabla
    )
    message("Descriptivos univariados numéricos generados")
  }

  # Crear lista de salida
  salida <- list(
    Numericas   = descriptivos_num,
    Categoricas = descriptivos_cat
  )

  # Guardar en un atributo si se aplicó ponderación
  attr(salida, "peso") <- !is.null(var_peso)

  salida
}

