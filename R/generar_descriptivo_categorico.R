#' Generar descriptivos para una variable categórica
#'
#' Calcula las frecuencias, porcentajes y sus intervalos de confianza (Wilson) para una variable categórica,
#' opcionalmente agrupada y ponderada. Además, permite pivotear la tabla resultante a formato ancho si se está
#' trabajando con un tibble agrupado.
#'
#' @param datos Data frame o tibble que contiene la variable a analizar.
#' @param var_categorica Nombre (carácter) de la variable categórica.
#' @param vars_grupo Vector de nombres de variables de agrupación. Si \code{datos} ya está agrupado, se utilizarán
#'   los grupos definidos en el objeto.
#' @param var_peso Nombre (carácter) de la variable de pesos. Si es \code{NULL} (por defecto), se realizan recuentos simples.
#' @param pivot Lógico. Si \code{TRUE} (por defecto) y el data frame está agrupado, se pivota la tabla (wide)
#'   utilizando la variable de agrupación o la variable categórica, según lo definido en \code{variable_pivot}.
#' @param variable_pivot Vector de caracteres que indica la variable a utilizar para pivotear: \code{"var_grupo"} o
#'   \code{"var_categorica"}. Por defecto es \code{c("var_grupo", "var_categorica")}.
#' @param nivel_confianza Nivel de confianza para los intervalos. Por defecto es \code{0.95}.
#' @param estrategia_valoresPerdidos Estrategia para el manejo de valores faltantes en la variable categórica. Se debe elegir
#'   \code{"E"} para eliminar o \code{"A"} para agrupar (NS/NC). Por defecto es \code{c("E", "A")}, de modo que se selecciona
#'   \code{"E"}.
#'
#' @return Data frame con los descriptivos calculados para la variable categórica, que incluye:
#' \itemize{
#'   \item \code{n}: Frecuencia (ponderada, si se especifica) de cada categoría.
#'   \item \code{n_sinW}: Frecuencia sin ponderar (solo si se especifica la variable de peso).
#'   \item \code{p}: Porcentaje calculado.
#'   \item \code{p_Min} y \code{p_Max}: Límites inferior y superior del intervalo de confianza, ajustados con el nivel de confianza.
#'   \item \code{sd}: Error estándar aproximado de la proporción.
#' }
#'
#' @details
#' La función realiza los siguientes pasos:
#' \enumerate{
#'   \item Se asegura que la variable categórica sea de tipo carácter, incluso si originalmente es numérica.
#'   \item Si \code{datos} está agrupado, se utiliza la(s) variable(s) de agrupación.
#'   \item Se cuentan las ocurrencias (ponderadas, si se especifica) de cada categoría.
#'   \item Se calcula el porcentaje de cada categoría. En caso de tener valores faltantes, se aplica la estrategia seleccionada:
#'         \describe{
#'           \item{\code{"E"}}{Elimina las observaciones faltantes (no se contabilizan en los porcentajes).}
#'           \item{\code{"A"}}{Agrupa los faltantes en la categoría \code{"NS/NC"}.}
#'         }
#'   \item Se ordena el resultado en función de la variable (descendente si es carácter, ascendente si es numérica).
#'   \item Se calculan intervalos de confianza utilizando el método de Wilson (se requiere la función \code{ci_margenError_pWilson}).
#'   \item Si \code{pivot} es \code{TRUE} y el data frame está agrupado, se pivota la tabla a formato ancho.
#'   \item Se añaden sufijos en los nombres de los intervalos de confianza según el nivel de confianza.
#' }
#'
#' @examples
#' \dontrun{
#'   library(dplyr)
#'   # Sin agrupación y sin pesos
#'   resultado <- generar_descriptivo_categorico(
#'                  datos = mtcars,
#'                  var_categorica = "cyl",
#'                  nivel_confianza = 0.95,
#'                  estrategia_valoresPerdidos = "E"
#'                )
#'
#'   # Con agrupación y pesos (suponiendo que 'w' es la variable de peso)
#'   resultado2 <- mtcars %>%
#'                  group_by(gear) %>%
#'                  generar_descriptivo_categorico(
#'                    var_categorica = "vs",
#'                    var_peso = "w",
#'                    pivot = TRUE,
#'                    variable_pivot = "var_grupo",
#'                    nivel_confianza = 0.95,
#'                    estrategia_valoresPerdidos = "A"
#'                  )
#' }
#'
#' @export
generar_descriptivo_categorico <- function(
    datos,
    var_categorica,
    vars_grupo = NULL,
    var_peso = NULL,
    pivot = TRUE,
    variable_pivot = c("var_grupo", "var_categorica"),
    nivel_confianza = 0.95,
    estrategia_valoresPerdidos = c("E", "A")
) {
  # Convertir la variable categórica a carácter si es numérica
  if (is.numeric(datos[[var_categorica]])) {
    datos[[var_categorica]] <- as.character(datos[[var_categorica]])
  }

  # Si 'datos' está agrupado, se usan las variables de agrupación definidas en el objeto
  if (is.grouped_df(datos)) {
    vars_grupo <- group_vars(datos)
  }

  # Si se especifican variables de agrupación, volver a agrupar (opcional)
  if (!is.null(vars_grupo)) {
    datos <- datos %>% group_by(!!!syms(vars_grupo))
  }

  # Crear símbolo para la variable categórica (evaluación tidy)
  var_sym <- sym(var_categorica)

  # Calcular recuentos: ponderados si se especifica la variable de peso, o simples
  if (is.null(var_peso)) {
    salida <- datos %>% count(!!var_sym)
  } else {
    w_sym <- sym(var_peso)
    salida <- datos %>% count(!!var_sym, wt = !!w_sym) %>%  mutate(n = round(n, 1))
    # Añadir recuento sin ponderar
    salida <- salida %>%
      left_join(datos %>% count(!!var_sym, name = "n_sinW"))
  }

  # Manejo de valores faltantes
  if (!any(is.na(datos[[var_categorica]]))) {
    salida <- salida %>% mutate(p = n / sum(n))
  } else {
    estrategia_valoresPerdidos <- match.arg(estrategia_valoresPerdidos)
    if (estrategia_valoresPerdidos == "E") {
      # Eliminar faltantes para el cálculo de porcentajes
      salida <- salida %>% filter(!is.na(!!var_sym)) %>%
        mutate(p = n / sum(n))
    } else if (estrategia_valoresPerdidos == "A") {
      # Agrupar faltantes bajo la categoría "NS/NC"
      salida[[var_categorica]] <- if_else(is.na(salida[[var_categorica]]),
                                          "NS/NC", salida[[var_categorica]])
      salida <- salida %>% mutate(p = n / sum(n))
    }
  }

  # Ordenar los resultados: descendente si la variable es de tipo carácter, ascendente si es numérica
  if (is.character(datos[[var_categorica]])) {
    salida <- salida %>% arrange(desc(p))
  } else {
    salida <- salida %>% arrange(!!sym(var_categorica))
  }

  # Calcular intervalos: se utiliza la función ci_margenError_pWilson (debe estar definida en el paquete)
  salida <- salida %>% mutate(
    N = sum(n),
    sd = sqrt(p * (1 - p) / N),
    p_Min = intervalo_confianza_pWilson(p = p, N = N, conf_level = nivel_confianza, limite = "inferior"),
    p_Max = intervalo_confianza_pWilson(p = p, N = N, conf_level = nivel_confianza, limite = "superior"),
    .after = p
  ) %>%
    select(-N) %>%
    relocate(sd, .after = p_Max)

  # Pivotear la tabla si se solicita y si 'datos' está agrupado
  if (pivot && is.grouped_df(datos)) {
    # Determinar la variable a utilizar para pivotear
    variable_pivot <- match.arg(variable_pivot)
    if (variable_pivot != "var_grupo") {
      variable_pivot <- var_categorica
    } else {
      variable_pivot <- vars_grupo
    }

    # Definir los valores a pivotear
    valores_pivot <- c("p", "p_Min", "p_Max", "n", "n_sinW", "sd")

    salida <- salida %>%
      ungroup() %>%
      tidyr::pivot_wider(
        names_from = all_of(variable_pivot),
        values_from = any_of(valores_pivot),
        names_glue = "{.name}_{.value}"
      )
    # Ajustar nombres de columnas eliminando prefijos no deseados
    colnames(salida) <- gsub("^p_Min_|^p_Max_|^sd_|^n_|^p_|^N_|^n_sinW_", "", colnames(salida))
  }

  # Añadir sufijo a los nombres de los intervalos según el nivel de confianza (por ejemplo, 95 para 0.95)
  chr_nivel <- as.character(stringr::str_split_i(as.character(nivel_confianza), "\\.", 2))
  salida <- salida %>%
    rename_with(
      .cols = contains(c("_Min", "_Max")),
      .fn = \(x) paste0(x, "_", chr_nivel)
    )

  salida
}
