
#' Función interna: extraer las diferencias de medias
#'
#' Función de uso interno en la función \(code){generar_descriptivo_numerico}. Tras haber
#' calculado el modelo lineal OLS, esta función se utiliza para extraer si exiten diferencias
#' significativas entre las medias de los grupos.
#'
#' Sólo se utiliza cuando se agrupa por una variable categórica.
#'
#' @param model_lm Modelo lineal calculado con \code{lm}
#' @param var_grupo Variable categórica incluida como variabe independiente.
#'
#' @returns Un tible con los coeficientes y el p.value.
#' @export
obtener_diferencia_medias <- function(model_lm, var_grupo ){
  broom::tidy(model_lm) %>%
    filter( !grepl('Intercept',term) ) %>%
    mutate( !!var_grupo := gsub(var_grupo,'',term)) %>%
    select( all_of(var_grupo) ,'Dif'=estimate, 'p_value' = p.value )
}
