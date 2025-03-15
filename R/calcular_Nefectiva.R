#' Calcular el Tamaño Efectivo de la Muestra
#'
#' Esta función calcula el tamaño efectivo de la muestra a partir de un vector de pesos,
#' usando la fórmula:
#'
#' \deqn{n_{\text{efectiva}} = \frac{(\sum pesos)^2}{\sum pesos^2}}
#'
#' Esta medida se utiliza en contextos de datos ponderados para reflejar la cantidad de información
#' equivalente a la de una muestra simple sin ponderar.
#'
#' @param pesos Numeric vector. Pesos asignados a cada observación.
#'
#' @return Numeric. El tamaño efectivo de la muestra.
#'
#' @details
#' El tamaño efectivo es útil para ajustar cálculos de error estándar e intervalos de confianza en análisis
#' donde se utilizan pesos, ya que la suma de los pesos no refleja directamente el número de observaciones
#' independientes.
#'
#' @examples
#' # Ejemplo sin ponderación (todos los pesos iguales):
#' calcular_Nefectiva(rep(1, 100))  # Debería dar 100
#'
#' # Ejemplo con pesos variables:
#' pesos <- c(0.5, 1.5, 1, 1, 2)
#' calcular_Nefectiva(pesos)
#'
#' @export
#'
calcular_Nefectiva <- function(pesos){
  sum(pesos)^2 / sum(pesos^2)
}
