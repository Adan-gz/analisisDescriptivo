#' Formatea una tabla categórica para Excel
#'
#' Esta función toma un data.frame o tibble y aplica formateo a los valores de porcentaje y, en caso de haber
#' una variable de agrupación, también formatea ciertos valores numéricos.
#' Dependiendo del parámetro \code{hay_var_grupo}, se aplican diferentes transformaciones:
#' \itemize{
#'   \item Si \code{hay_var_grupo} es \code{FALSE}, se formatean las columnas desde \code{p} hasta \code{sd} como porcentajes.
#'   \item Si \code{hay_var_grupo} es \code{TRUE}, se formatean columnas específicas de porcentaje (aquellas que terminan en \code{"_p"}, contienen \code{"_p_"} o terminan en \code{"_sd"}),
#'         se formatean columnas numéricas como \code{Chi2} y \code{VCramer} y se formatea la columna \code{p_value}.
#' }
#'
#' @param tabla Data.frame o tibble. La tabla a formatear.
#' @param hay_var_grupo Lógico. Indica si se ha utilizado una variable de agrupación.
#'   Si es \code{NULL}, se intenta obtener a partir del atributo \code{vars_grupo} de \code{tabla}.
#' @param precision_fac Número. Precisión para formatear porcentajes. Por defecto es 0.1.
#' @param escala_fac Número. Factor de escala para porcentajes. Por defecto es 100.
#' @param sufijo_fac Carácter. Sufijo a añadir a los porcentajes. Por defecto es "%".
#' @param estilo_positivo_fac Carácter. Estilo para valores positivos en porcentajes. Por defecto es "none".
#' @param separador_decimal Carácter. Separador decimal. Por defecto es ",".
#' @param separador_miles Carácter. Separador de miles. Por defecto es ".".
#' @param precision_num Número. Precisión para formatear valores numéricos en la rama con agrupación. Por defecto es 0.1.
#' @param escala_num Número. Factor de escala para formatear valores numéricos en la rama con agrupación. Por defecto es 1.
#' @param sufijo_num Carácter. Sufijo a añadir a los valores numéricos en la rama con agrupación. Por defecto es "".
#' @param prefijo_num Carácter. Prefijo a añadir a los valores numéricos en la rama con agrupación. Por defecto es "".
#' @param estilo_positivo_num Carácter. Estilo para valores positivos en la rama numérica dentro de la agrupación. Por defecto es "none".
#'
#' @return Devuelve el data.frame o tibble con los valores formateados según el tipo de variable.
#'
#' @details La función utiliza \code{dplyr::mutate} y \code{dplyr::across} para aplicar funciones de formateo:
#' \itemize{
#'   \item Si \code{hay_var_grupo} es \code{FALSE}, se aplica \code{scales::percent} a las columnas desde \code{p} hasta \code{sd}.
#'   \item Si \code{hay_var_grupo} es \code{TRUE}, se aplican \code{scales::percent} y \code{scales::number} a columnas específicas
#'         (por ejemplo, aquellas que terminan en \code{"_p"} o contienen \code{"_p_"} para porcentajes y columnas como \code{Chi2} y \code{VCramer} para valores numéricos),
#'         y se formatea la columna \code{p_value}.
#' }
#'
#' @examples
#' \dontrun{
#'   # Sin variable de grupo:
#'   df_formateado <- formatear_tabla_categorica(mi_dataframe, hay_var_grupo = FALSE)
#'
#'   # Con variable de grupo:
#'   df_formateado <- formatear_tabla_categorica(mi_dataframe, hay_var_grupo = TRUE)
#' }
#'
#' @importFrom dplyr mutate across any_of
#' @importFrom scales percent number
#' @export

formatear_tabla_categorica <- function(
    tabla,
    hay_var_grupo = NULL,
    precision_fac = 0.1,
    escala_fac = 100,
    sufijo_fac = "%",
    estilo_positivo_fac = "none",
    separador_decimal = ",",
    separador_miles = ".",
    precision_num = 0.1,
    escala_num  = 1,
    sufijo_num = "",
    prefijo_num = "",
    estilo_positivo_num = "none"
){

  if( is.null(hay_var_grupo) ){
    hay_var_grupo <- attr(tabla, 'vars_grupo')
    if( is.null(hay_var_grupo) ) stop("hay_var_grupo no detectado automáticamente. Se debe especificar TRUE o FALSE si se ha utilizado una variabla para agrupar como vars_grupo")
  }

  if (!hay_var_grupo) {

    tabla %>%
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
    tabla %>%
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
        'p_value' = scales::number(p_value,accuracy = .0001,decimal.mark = separador_decimal,big.mark = separador_miles)
      )
  }
}

