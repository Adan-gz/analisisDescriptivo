#' Calcular Test Chi-Cuadrado Ponderado para Dos Variables Categóricas
#'
#' Esta función calcula el test chi-cuadrado para evaluar la asociación entre dos variables categóricas,
#' incorporando pesos si se especifica. Se filtran observaciones con NA y se ajustan los pesos dividiéndolos
#' por su media (opcional) para estabilizar la estimación. Además, se eliminan niveles vacíos en caso de que las
#' variables sean factores.
#'
#' @param var1 Vector. Variable categórica (o convertible a factor) correspondiente a las filas.
#' @param var2 Vector. Variable categórica (o convertible a factor) correspondiente a las columnas.
#' @param weight Numeric vector (opcional). Pesos para cada observación. Si es \code{NULL}, se asume peso 1 para cada elemento.
#' @param na.rm Logical. Indica si se deben eliminar las observaciones con valores faltantes en \code{var1} o \code{var2}. Por defecto es \code{TRUE}.
#' @param drop.missing.levels Logical. Si \code{TRUE}, elimina los niveles vacíos de las variables categóricas. Por defecto es \code{TRUE}.
#' @param mean1 Logical. Si \code{TRUE}, los pesos se normalizan dividiéndolos por su media (calculada con \code{na.rm = TRUE}). Por defecto es \code{TRUE}.
#'
#' @return Una lista que contiene:
#' \item{Chisq}{El estadístico chi-cuadrado calculado.}
#' \item{df}{Los grados de libertad del test.}
#' \item{p.value}{El valor p asociado al test.}
#' \item{tabla}{La tabla de contingencia ponderada generada con \code{xtabs()}.}
#'
#' @details
#' La función utiliza \code{xtabs()} para construir una tabla de contingencia ponderada y \code{summary()} para extraer
#' los parámetros del test chi-cuadrado. La normalización de los pesos puede ayudar a estabilizar la estimación, especialmente
#' cuando se trabajan con escalas muy diferentes.
#'
#' @examples
#' \dontrun{
#' # Ejemplo con datos simulados:
#' set.seed(123)
#' var1 <- sample(LETTERS[1:3], 100, replace = TRUE)
#' var2 <- sample(c("X", "Y"), 100, replace = TRUE)
#' pesos <- runif(100, 0.5, 1.5)
#' res_chi <- calcular_chi2(var1, var2, weight = pesos)
#' res_chi
#' }
#' @export
calcular_chi2 <- function(
    var1,
    var2,
    weight = NULL,
    na.rm = TRUE,
    drop.missing.levels = TRUE,
    mean1 = TRUE) {
  # Si no se especifican pesos, se asigna 1 a cada observación
  if (is.null(weight)) {
    weight <- rep(1, length(var1))
  }

  # Ajuste de los pesos: dividir por la media, si se solicita
  if (mean1) {
    weight <- weight / mean(weight, na.rm = TRUE)
  }

  # Filtrar NAs en var1 y var2, si es requerido
  if (na.rm) {
    filt <- !is.na(var1) & !is.na(var2)
    var1 <- var1[filt]
    var2 <- var2[filt]
    weight <- weight[filt]
  }

  # Eliminar niveles faltantes si las variables son factores
  if (drop.missing.levels) {
    if (is.factor(var1)) var1 <- droplevels(var1)
    if (is.factor(var2)) var2 <- droplevels(var2)
  }

  # Construir la tabla ponderada
  tab <- xtabs(weight ~ var1 + var2)

  # Calcular el test chi-cuadrado a partir de la tabla y extraer estadísticas relevantes
  res <- summary(tab)[c("statistic", "parameter", "p.value")]
  names(res) <- c("Chisq", "df", "p.value")

  append( res, list('tabla'=tab) )
}
