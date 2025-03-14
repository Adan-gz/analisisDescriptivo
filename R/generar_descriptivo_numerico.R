#' Generar descriptivo para una variable numérica
#'
#' Calcula medidas descriptivas básicas para una variable numérica, incluyendo conteos, estadísticos (media, mediana, cuantiles, etc.),
#' desviación estándar y un histograma inline. Además, calcula intervalos de confianza para la media utilizando el margen de error.
#' Si se especifica una variable de pesos, se calculan estadísticas ponderadas y se utiliza el tamaño muestral efectivo para el intervalo.
#'
#' @param datos Data frame o tibble que contiene la variable numérica a analizar.
#' @param var_numerica Nombre (carácter) de la variable numérica a analizar.
#' @param vars_grupo Vector de nombres de variables para agrupar. Si es \code{NULL} (por defecto), no se realiza agrupamiento.
#' @param var_peso Nombre (carácter) de la variable de peso. Si es \code{NULL} (por defecto), se calculan estadísticas sin ponderar.
#' @param digits Valor de precisión para formateos numéricos (por defecto \code{0.1}). Actualmente se reserva para un futuro formateo.
#' @param nivel_confianza Nivel de confianza para el cálculo de intervalos (por defecto \code{0.95}).
#'
#' @return Data frame con las estadísticas descriptivas calculadas. Entre las variables se incluyen:
#' \itemize{
#'   \item \code{Variable}: Nombre de la variable.
#'   \item \code{N}: Número de observaciones completas.
#'   \item \code{Missing}: Número de observaciones faltantes.
#'   \item \code{Media}: Promedio de la variable.
#'   \item \code{Min}: Valor mínimo.
#'   \item \code{Q25}: Primer cuartil.
#'   \item \code{Mediana}: Mediana.
#'   \item \code{Q75}: Tercer cuartil.
#'   \item \code{Max}: Valor máximo.
#'   \item \code{sd}: Desviación estándar.
#'   \item \code{hist}: Histograma inline.
#'   \item \code{Media_Min} y \code{Media_Max} (o \code{Media_w_Min} y \code{Media_w_Max} en caso de ponderación): Límites inferior y superior del intervalo de confianza.
#' }
#'
#' @details
#' La función realiza los siguientes pasos:
#' \enumerate{
#'   \item Se asegura que la variable sea de tipo \code{numeric}.
#'   \item Si se especifican variables de agrupación, se agrupa el data frame.
#'   \item Se calculan medidas descriptivas básicas utilizando \code{dplyr::summarise} y funciones de \code{skimr}.
#'   \item Si no se especifica una variable de peso, se calcula el intervalo de confianza para la media basándose en
#'         el conteo (\code{N}) y la desviación estándar (\code{sd}) mediante la función \code{margenError_num}.
#'   \item Si se especifica la variable de peso, se calculan la media y desviación estándar ponderadas, además del
#'         tamaño muestral efectivo (\code{N_eff}), y se computan los intervalos correspondientes.
#'   \item Se renombrarán las columnas de intervalos, añadiéndoles un sufijo que indica el nivel de confianza.
#' }
#'
#' @examples
#' \dontrun{
#'   # Ejemplo sin ponderación:
#'   resumen <- generar_descriptivo_numerico(
#'                datos = mtcars,
#'                var_numerica = "mpg",
#'                nivel_confianza = 0.95
#'              )
#'
#'   # Ejemplo con ponderación (suponiendo que 'wt' es la variable de peso):
#'   resumen_ponderado <- generar_descriptivo_numerico(
#'                           datos = mtcars,
#'                           var_numerica = "mpg",
#'                           var_peso = "wt",
#'                           nivel_confianza = 0.95
#'                         )
#' }
#'
#' @export
generar_descriptivo_numerico <- function(
    datos,
    var_numerica,
    vars_grupo = NULL,
    var_peso = NULL,
    digits = 0.1,
    nivel_confianza = 0.95
) {
  # Asegurarse de que la variable es de tipo numeric
  if (is.numeric(datos[[var_numerica]]) != "numeric") {
    datos[[var_numerica]] <- as.numeric(datos[[var_numerica]])
  }

  # Si se especifica la variable de peso, crear símbolo para evaluación tidy
  if (!is.null(var_peso)) {
    w_sym <- sym(var_peso)
  }

  # Si se especifican variables de agrupación, agrupar el data frame
  if (!is.null(vars_grupo)) {
    datos <- datos %>% group_by(!!!syms(vars_grupo))
  }

  # Crear símbolo para la variable numérica
  var_sym <- sym(var_numerica)

  # Calcular medidas descriptivas básicas usando funciones de skimr y dplyr
  salida <- datos %>%
    dplyr::summarise(
      Variable = var_numerica,
      N = skimr::n_complete(!!var_sym),
      Missing = skimr::n_missing(!!var_sym),
      Media = mean(!!var_sym, na.rm = TRUE),
      Min = min(!!var_sym, na.rm = TRUE),
      Q25 = quantile(!!var_sym, 0.25, na.rm = TRUE),
      Mediana = median(!!var_sym, na.rm = TRUE),
      Q75 = quantile(!!var_sym, 0.75, na.rm = TRUE),
      Max = max(!!var_sym, na.rm = TRUE),
      sd = sd(!!var_sym, na.rm = TRUE),
      hist = skimr::inline_hist(!!var_sym),
      .groups = "drop"
    )

  # Si no se especifica variable de peso, calcular intervalos de confianza basados en N y sd
  if (is.null(var_peso)) {
    salida <- salida %>%
      mutate(
        Media_Min = Media - margen_error_media(N = N, sd = sd, conf_level = nivel_confianza),
        Media_Max = Media + margen_error_media(N = N, sd = sd, conf_level = nivel_confianza),
        .after = Media
      )
  } else {
    # Calcular medidas ponderadas: media, desviación y tamaño muestral efectivo
    salida_w <- datos %>%
      filter(!is.na(!!var_sym)) %>%
      summarise(
        N_w = sum(!!w_sym, na.rm = TRUE),                   # Tamaño de muestra ponderado
        N_eff = (sum(!!w_sym, na.rm = TRUE)^2) / sum((!!w_sym)^2, na.rm = TRUE), # Tamaño muestral efectivo
        Media_w = weighted.mean(!!var_sym, w = !!w_sym, na.rm = TRUE),
        sd_w = desviacion_estandar_ponderada(!!var_sym, pesos = !!w_sym)
      )
    # Unir la información de estadísticas sin y con ponderación
    if (is.grouped_df(datos)) {
      salida <- salida %>% left_join(salida_w)
    } else {
      salida <- salida %>% bind_cols(salida_w)
    }

    # Calcular intervalos de confianza para la media ponderada
    salida <- salida %>%
      mutate(
        Media_w_Min = Media_w - margen_error_media(N = N_eff, sd = sd_w, conf_level = nivel_confianza),
        Media_w_Max = Media_w + margen_error_media(N = N_eff, sd = sd_w, conf_level = nivel_confianza)
      ) %>%
      relocate(N_w, N_eff, .after = N) %>%
      relocate(Media_w, Media_w_Min, Media_w_Max, .after = Media) %>%
      relocate(sd_w, .after = sd)
  }

  # Renombrar columnas de intervalos añadiendo un sufijo que indica el nivel de confianza
  salida <- salida %>% rename_with(
    .cols = ends_with(c("_Min", "_Max")),
    .fn = \(x) paste0(x, "_", as.character(stringr::str_split_i(as.character(nivel_confianza), "\\.", 2)))
  )

  # Se podría aplicar formateo numérico adicional si fuera necesario (por ejemplo, con una función similar a number())
  salida
}
