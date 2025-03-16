#' Calcular la V de Cramer a partir del Resultado de un Test Chi-Cuadrado Ponderado
#'
#' Esta función calcula la V de Cramer, una medida de asociación entre dos variables categóricas,
#' a partir del resultado obtenido por \code{calcular_chi2()}. Se utiliza la fórmula:
#'
#' \deqn{V = \sqrt{\frac{\chi^2}{n \times \min(k - 1, r - 1)}},}
#'
#' donde \(\chi^2\) es el estadístico chi-cuadrado, \(n\) es el total de observaciones (o la suma de la tabla
#' de contingencia) y \(k\) y \(r\) son el número de filas y columnas, respectivamente.
#'
#' @param resultado_chi2 Lista. Salida de \code{calcular_chi2()}, que debe incluir el elemento \code{tabla} y
#' los valores del estadístico chi-cuadrado.
#'
#' @return Numeric. El valor de la V de Cramer.
#'
#' @details
#' La V de Cramer varía entre 0 y 1, donde 0 indica ausencia de asociación y 1 una asociación perfecta.
#' Se utiliza el tamaño total de la tabla de contingencia (calculado como la suma de todos los pesos) y se
#' ajusta por los grados de libertad mínimos entre las filas y columnas.
#'
#' @examples
#' \dontrun{
#' # Supongamos que res_chi es el resultado de calcular_chi2()
#' set.seed(123)
#' var1 <- sample(LETTERS[1:3], 100, replace = TRUE)
#' var2 <- sample(c("X", "Y"), 100, replace = TRUE)
#' pesos <- runif(100, 0.5, 1.5)
#' res_chi <- calcular_chi2(var1, var2, weight = pesos)
#' v_cramer <- calcular_VCramer(res_chi)
#' v_cramer
#' }
#'
#' @export
calcular_VCramer <- function(resultado_chi2) {
  n <- sum(resultado_chi2$tabla)
  min_df <- min(nrow(resultado_chi2$tabla) - 1, ncol(resultado_chi2$tabla) - 1)
  v <- sqrt(resultado_chi2$Chisq / (n * min_df))
  v
}
