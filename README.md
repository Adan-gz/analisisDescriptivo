
<!-- README.md is generated from README.Rmd. Please edit that file -->

# analisisDescriptivo

<!-- badges: start -->
<!-- badges: end -->

`analisisDescriptivo` es un paquete de R diseñado para facilitar la
generación de estadísticas descriptivas para variables numéricas y
categóricas. Proporciona funciones para análisis univariado, análisis
agrupado (bivariado) y herramientas para formatear los resultados para
su exportación, por ejemplo, a Excel. Además, calcula los intervalos de
confianza de las medias y proporciones (con y sin variable de
ponderación), calcula si las diferencias de medias son significativas
entre grupos (a través de OLS) y si hay diferencia significativa entre
dos variables categóricas (mediante chi cuadrado).

## Advertencia

Actualmente, este documento así como la documentación de las funciones
está elaborado principalmente a través del modelo 03-mini de ChatGPT,
por lo que puede haber algún error.

Tampoco se explica, por ahora, con todo detalle las funcionalidades del
paquete.

Esta tarea está pendiente de llevarse a cabo.

## Características

- **Análisis descriptivo categórico:** Calcula frecuencias, porcentajes
  y sus intervalos de confianza (usando el método de Wilson) para
  variables categóricas (con o sin ponderar).

<!-- -->

- **Análisis descriptivo numérico:** Obtén estadísticas básicas (media,
  mediana, cuantiles, desviación estándar, histograma inline) de
  variables numéricas (con o sin ponderar)..

<!-- -->

- **Análisis agrupado:** Genera de forma sencilla descriptivos numéricos
  y categóricos agrupando por las categorías de una variable categórica.

<!-- -->

- **Exportación a Excel:** Formatea y concatena tablas de resultados
  para exportarlas a una única hoja de Excel.

## Instalación

Puedes instalar la versión de desarrollo de `analisisDescriptivo` desde
GitHub con:

``` r
# install.packages("remotes")
remotes::install_github("Adan-gz/analisisDescriptivo")
```

## Uso Rápido

A continuación, se muestra un ejemplo básico que ilustra cómo generar
estadísticas descriptivas utilizando el paquete:

``` r

library(analisisDescriptivo)

# Análisis descriptivo univariado (tanto numérico como categórico)
resultados_univ <- generar_descriptivos_univariados(
  datos = mtcars,
  var_peso = "wt", 
  return_df = TRUE
)
#> Warning: Model has 32 prior weights, but we recovered 2 rows of data.
#> So prior weights were ignored.
#> Warning: Model has 32 prior weights, but we recovered 2 rows of data.
#> So prior weights were ignored.
#> Warning: Model has 32 prior weights, but we recovered 2 rows of data.
#> So prior weights were ignored.
#> Warning: Model has 32 prior weights, but we recovered 2 rows of data.
#> So prior weights were ignored.
#> Warning: Model has 32 prior weights, but we recovered 2 rows of data.
#> So prior weights were ignored.
#> Warning: Model has 32 prior weights, but we recovered 2 rows of data.
#> So prior weights were ignored.
#> Warning: Model has 32 prior weights, but we recovered 2 rows of data.
#> So prior weights were ignored.
#> Warning: Model has 32 prior weights, but we recovered 2 rows of data.
#> So prior weights were ignored.
#> Warning: Model has 32 prior weights, but we recovered 2 rows of data.
#> So prior weights were ignored.
#> Warning: Model has 32 prior weights, but we recovered 2 rows of data.
#> So prior weights were ignored.
#> Warning: Model has 32 prior weights, but we recovered 2 rows of data.
#> So prior weights were ignored.
#> Descriptivos univariados numéricos generados
print(resultados_univ)
#> $Numericas
#> # A tibble: 11 × 15
#>    Variable     N Missing   Media Media_w Media_w_Min_95 Media_w_Max_95   Min
#>    <chr>    <int>   <int>   <dbl>   <dbl>          <dbl>          <dbl> <dbl>
#>  1 mpg         32       0  20.1    18.5           16.6           20.5   10.4 
#>  2 cyl         32       0   6.19    6.60           5.99           7.21   4   
#>  3 disp        32       0 231.    263.           218.           309.    71.1 
#>  4 hp          32       0 147.    160.           136.           184.    52   
#>  5 drat        32       0   3.60    3.48           3.30           3.67   2.76
#>  6 wt          32       0   3.22    3.51           3.15           3.87   1.51
#>  7 qsec        32       0  17.8    17.8           17.1           18.4   14.5 
#>  8 vs          32       0   0.438   0.355          0.180          0.530  0   
#>  9 am          32       0   0.406   0.304          0.136          0.473  0   
#> 10 gear        32       0   3.69    3.56           3.30           3.82   3   
#> 11 carb        32       0   2.81    3.02           2.44           3.59   1   
#> # ℹ 7 more variables: Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>,
#> #   sd_w <dbl>, hist <chr>
#> 
#> $Categoricas
#> NULL
#> 
#> attr(,"peso")
#> [1] TRUE

# Análisis descriptivo agrupado por la variable 'gear'
resultados_agrupados <- generar_descriptivos_agrupados(
  datos = mtcars,
  vars_grupo = "gear",
  vars_numericas = c("mpg", "hp"),
  vars_categoricas = "cyl",
  var_peso = "wt",
  nivel_confianza = 0.95
)
#> Los intervalos de confianza de las proporciones se calculan mediante la N efectiva
#> Joining with `by = join_by(gear)`
#> Joining with `by = join_by(gear, cyl)`
#> Descriptivos agrupados categóricos generados
#> Joining with `by = join_by(gear)`
#> Joining with `by = join_by(gear)`
#> Joining with `by = join_by(gear)`
#> Joining with `by = join_by(gear)`
#> Joining with `by = join_by(gear)`
#> Joining with `by = join_by(gear)`
#> Descriptivos agrupados numéricos generados
print(resultados_agrupados)
#> $Numericas
#> $Numericas$mpg
#> # A tibble: 3 × 18
#>   gear  Variable     N Missing Media Media_w   Dif    p_value Media_w_Min_95
#>   <chr> <chr>    <int>   <int> <dbl>   <dbl> <dbl>      <dbl>          <dbl>
#> 1 3     mpg         15       0  16.1    15.6 NA    NA                   13.5
#> 2 4     mpg         12       0  24.5    23.6  7.99  0.0000609           20.8
#> 3 5     mpg          5       0  21.4    19.7  4.16  0.0875              15.4
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>, hist <chr>
#> 
#> $Numericas$hp
#> # A tibble: 3 × 18
#>   gear  Variable     N Missing Media Media_w   Dif   p_value Media_w_Min_95
#>   <chr> <chr>    <int>   <int> <dbl>   <dbl> <dbl>     <dbl>          <dbl>
#> 1 3     hp          15       0 176.    182.   NA   NA                 158. 
#> 2 4     hp          12       0  89.5    93.7 -88.6  0.000146           60.3
#> 3 5     hp           5       0 196.    219.   36.7  0.199             167. 
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>, hist <chr>
#> 
#> 
#> $Categoricas
#> $Categoricas$cyl
#> # A tibble: 3 × 25
#>   cyl   gear_p_3_p gear_p_4_p gear_p_5_p `3_p_Min_95` `4_p_Min_95` `5_p_Min_95`
#>   <chr>      <dbl>      <dbl>      <dbl>        <dbl>        <dbl>        <dbl>
#> 1 8         0.843      NA          0.512      0.589         NA           0.170 
#> 2 4         0.0422      0.606      0.278      0.00517        0.332       0.0605
#> 3 6         0.114       0.394      0.210      0.0284         0.174       0.0375
#> # ℹ 18 more variables: `3_p_Max_95` <dbl>, `4_p_Max_95` <dbl>,
#> #   `5_p_Max_95` <dbl>, `3_n` <dbl>, `4_n` <dbl>, `5_n` <dbl>, `3_sd` <dbl>,
#> #   `4_sd` <dbl>, `5_sd` <dbl>, `3_p_sinW` <dbl>, `4_p_sinW` <dbl>,
#> #   `5_p_sinW` <dbl>, `3_n_sinW` <int>, `4_n_sinW` <int>, `5_n_sinW` <int>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> 
#> attr(,"vars_grupo")
#> [1] TRUE
#> attr(,"peso")
#> [1] TRUE


resultados_agrupados_automaticos <- generar_descriptivos_agrupados( 
  datos = mtcars,
  vars_grupo = 'cyl', 
  selecc_vars_auto = TRUE
)
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Joining with `by = join_by(cyl)`
#> Descriptivos agrupados numéricos generados

# Formatear los descriptivos univariados para exportar a Excel en 1 única hoja
hoja_excel <- generar_hoja_excel_descriptivos(resultados_agrupados_automaticos)
```

## Uso Avanzado

El paquete incluye funciones para personalizar el análisis:

- **`generar_descriptivo_categorico`**: Genera estadísticas descriptivas
  para una variable categórica.

- **`generar_descriptivo_numerico`**: Genera estadísticas descriptivas
  para una variable numérica.

- **`preparar_tabla_excel`**: Prepara una tabla para su exportación a
  Excel, incluyendo encabezados y formateo.

- **`concatenar_tablas_excel`**: Concatena múltiples tablas (tibbles) en
  un único data frame, separadas por filas vacías.

Consulta la documentación de cada función (por ejemplo,
`?generar_descriptivo_categorico`) para obtener más detalles.

## Contribución

¡Las contribuciones, informes de errores y solicitudes de nuevas
funcionalidades son bienvenidos!  
Por favor, abre un issue o envía un pull request en
[GitHub](https://github.com/Adan-gz/analisisDescriptivo).

## Licencia

Este paquete está disponible bajo la Licencia MIT.
