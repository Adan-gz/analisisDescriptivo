#' Formatea una tabla numérica para Excel
#'
#' Esta función toma un data.frame o tibble y aplica formateo numérico a sus columnas.
#' Se formatean las columnas numéricas (exceptuando las columnas 'N', 'Missing' y 'p_value')
#' utilizando \code{scales::number}. Además, se formatea la columna \code{p_value} con mayor precisión.
#'
#' @param tabla Data.frame o tibble. La tabla que se desea formatear.
#' @param precision_num Número. Precisión para formatear los números. Por defecto es 0.1.
#' @param escala_num Número. Factor de escala para formatear los números. Por defecto es 1.
#' @param sufijo_num Carácter. Sufijo a añadir a los números. Por defecto es "".
#' @param prefijo_num Carácter. Prefijo a añadir a los números. Por defecto es "".
#' @param estilo_positivo_num Carácter. Estilo a aplicar a números positivos. Por defecto es "none".
#' @param separador_decimal Carácter. Separador decimal. Por defecto es ",".
#' @param separador_miles Carácter. Separador de miles. Por defecto es ".".
#'
#' @return Devuelve el data.frame o tibble con las columnas numéricas formateadas.
#'
#' @details Se utiliza \code{dplyr::mutate} junto con \code{dplyr::across} para aplicar la función
#' \code{scales::number} a las columnas numéricas, exceptuando aquellas identificadas como 'N', 'Missing' o 'p_value'.
#' La columna \code{p_value} se formatea utilizando una precisión mayor.
#'
#' @examples
#' \dontrun{
#'   df_formateado <- formatear_tabla_numerica(mi_dataframe)
#' }
#'
#' @importFrom dplyr mutate across where any_of
#' @importFrom scales number
#' @export
formatear_tabla_numerica <- function(
    tabla,
    precision_num = 0.1,
    escala_num  = 1,
    sufijo_num = "",
    prefijo_num = "",
    estilo_positivo_num = "none",
    separador_decimal = ",",
    separador_miles = "."

    ){
  tabla %>%
    mutate(
      across(
        any_of(c('R2','R2_w','OLS_coef','OLS_coef_w')),
        function(x) {
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

      across(
        any_of(c('p_value','OLS_p_value','OLS_p_value_w')),
        \(x) scales::number(x,accuracy = .0001,decimal.mark = separador_decimal,big.mark = separador_miles)
      ),

      across(
        c(where(is.numeric), -any_of(c('N', 'Missing', 'p_value','R2','R2_w','OLS_coef','OLS_coef_w'))),
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
      )
    )
}

