#' Obtener Fórmula para Modelos Lineales
#'
#' Genera una fórmula en formato R a partir de una variable dependiente y un vector de variables independientes.
#'
#' @param VD Character. Nombre de la variable dependiente.
#' @param Xs Character vector. Nombre(s) de la(s) variable(s) independiente(s).
#'
#' @return Un objeto de clase \code{formula} en el formato \code{VD ~ X1 + X2 + ...}.
#'
#' @details
#' La función utiliza \code{paste0} para concatenar los nombres de las variables independientes,
#' generando así una fórmula que puede usarse en funciones como \code{lm()}.
#'
#' @examples
#' \dontrun{
#' # Generar una fórmula para ajustar un modelo lineal:
#' formula_modelo <- obtener_formula("mpg", c("cyl", "hp"))
#' print(formula_modelo)
#' }
#'
#' @export

obtener_formula <- function(VD,Xs){
  as.formula(paste0(VD,'~',paste0(Xs,collapse = '+')))
}
