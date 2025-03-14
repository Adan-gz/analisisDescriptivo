
<!-- README.md is generated from README.Rmd. Please edit that file -->

# analisisDescriptivo

<!-- badges: start -->
<!-- badges: end -->

`analisisDescriptivo` es un paquete de R diseñado para facilitar la
generación de estadísticas descriptivas para variables numéricas y
categóricas. Proporciona funciones para análisis univariado, análisis
agrupado (bivariado) y herramientas para formatear los resultados para
su exportación, por ejemplo, a Excel.

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

## Installation

You can install the development version of analisisDescriptivo from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Adan-gz/analisisDescriptivo")
```

## Instalación

Puedes instalar la versión de desarrollo de `analisisDescriptivo` desde
GitHub con:

``` r
# install.packages("remotes")
remotes::install_github("Adan-gz/analisisDescriptivo")
#> Using GitHub PAT from the git credential store.
#> Downloading GitHub repo Adan-gz/analisisDescriptivo@HEAD
#> rlang  (1.1.4  -> 1.1.5 ) [CRAN]
#> glue   (1.7.0  -> 1.8.0 ) [CRAN]
#> cli    (3.6.3  -> 3.6.4 ) [CRAN]
#> purrr  (1.0.2  -> 1.0.4 ) [CRAN]
#> digest (0.6.36 -> 0.6.37) [CRAN]
#> Installing 5 packages: rlang, glue, cli, purrr, digest
#> Installing packages into 'C:/Users/34673/AppData/Local/Temp/RtmpAZ0hAF/temp_libpath310c742c4776'
#> (as 'lib' is unspecified)
#> package 'rlang' successfully unpacked and MD5 sums checked
#> package 'glue' successfully unpacked and MD5 sums checked
#> package 'cli' successfully unpacked and MD5 sums checked
#> package 'purrr' successfully unpacked and MD5 sums checked
#> package 'digest' successfully unpacked and MD5 sums checked
#> 
#> The downloaded binary packages are in
#>  C:\Users\34673\AppData\Local\Temp\Rtmp8oAIyv\downloaded_packages
#> ── R CMD build ─────────────────────────────────────────────────────────────────
#>       ✔  checking for file 'C:\Users\34673\AppData\Local\Temp\Rtmp8oAIyv\remotes22d864cd677d\Adan-gz-analisisDescriptivo-52f1233/DESCRIPTION'
#>       ─  preparing 'analisisDescriptivo':
#>    checking DESCRIPTION meta-information ...     checking DESCRIPTION meta-information ...   ✔  checking DESCRIPTION meta-information
#>       ─  checking for LF line-endings in source and make files and shell scripts
#>   ─  checking for empty or unneeded directories
#>       ─  building 'analisisDescriptivo_0.0.0.9000.tar.gz'
#>      
#> 
#> Installing package into 'C:/Users/34673/AppData/Local/Temp/RtmpAZ0hAF/temp_libpath310c742c4776'
#> (as 'lib' is unspecified)
```

## Uso Rápido

A continuación, se muestra un ejemplo básico que ilustra cómo generar
estadísticas descriptivas utilizando el paquete:

``` r

library(analisisDescriptivo)

# Análisis descriptivo univariado (tanto numérico como categórico)
resultados_univ <- generar_descriptivos_univariados(
  datos = mtcars,
  var_peso = "wt"
)
#> Descriptivos univariados numéricos generados
print(resultados_univ)
#> $Numericas
#> $Numericas$mpg
#>   Variable  N     N_w    N_eff Missing    Media  Media_w Media_w_Min_95
#> 1      mpg 32 102.952 29.36848       0 20.09062 18.54993       16.48476
#>   Media_w_Max_95  Min    Q25 Mediana  Q75  Max       sd     sd_w     hist
#> 1       20.61511 10.4 15.425    19.2 22.8 33.9 6.026948 5.466831 ▃▇▇▇▃▂▂▂
#> 
#> $Numericas$cyl
#>   Variable  N     N_w    N_eff Missing  Media  Media_w Media_w_Min_95
#> 1      cyl 32 102.952 29.36848       0 6.1875 6.599231       5.964794
#>   Media_w_Max_95 Min Q25 Mediana Q75 Max       sd     sd_w     hist
#> 1       7.233667   4   4       6   8   8 1.785922 1.679448 ▆▁▁▃▁▁▁▇
#> 
#> $Numericas$disp
#>   Variable  N     N_w    N_eff Missing    Media  Media_w Media_w_Min_95
#> 1     disp 32 102.952 29.36848       0 230.7219 263.1468       215.9698
#>   Media_w_Max_95  Min     Q25 Mediana Q75 Max       sd     sd_w     hist
#> 1       310.3238 71.1 120.825   196.3 326 472 123.9387 124.8846 ▇▆▁▂▅▃▁▂
#> 
#> $Numericas$hp
#>   Variable  N     N_w    N_eff Missing    Media  Media_w Media_w_Min_95
#> 1       hp 32 102.952 29.36848       0 146.6875 159.9944        134.717
#>   Media_w_Max_95 Min  Q25 Mediana Q75 Max       sd     sd_w     hist
#> 1       185.2718  52 96.5     123 180 335 68.56287 66.91301 ▃▇▃▅▂▃▁▁
#> 
#> $Numericas$drat
#>   Variable  N     N_w    N_eff Missing    Media  Media_w Media_w_Min_95
#> 1     drat 32 102.952 29.36848       0 3.596563 3.484332       3.295567
#>   Media_w_Max_95  Min  Q25 Mediana  Q75  Max        sd      sd_w     hist
#> 1       3.673097 2.76 3.08   3.695 3.92 4.93 0.5346787 0.4996883 ▃▇▁▅▇▂▁▁
#> 
#> $Numericas$wt
#>   Variable  N     N_w    N_eff Missing   Media  Media_w Media_w_Min_95
#> 1       wt 32 102.952 29.36848       0 3.21725 3.505528       3.132122
#>   Media_w_Max_95   Min     Q25 Mediana  Q75   Max        sd      sd_w     hist
#> 1       3.878933 1.513 2.58125   3.325 3.61 5.424 0.9784574 0.9884601 ▃▃▃▇▆▁▁▂
#> 
#> $Numericas$qsec
#>   Variable  N     N_w    N_eff Missing    Media  Media_w Media_w_Min_95
#> 1     qsec 32 102.952 29.36848       0 17.84875 17.75677       17.10277
#>   Media_w_Max_95  Min     Q25 Mediana  Q75  Max       sd     sd_w     hist
#> 1       18.41076 14.5 16.8925   17.71 18.9 22.9 1.786943 1.731218 ▃▂▇▆▃▃▁▁
#> 
#> $Numericas$vs
#>   Variable  N     N_w    N_eff Missing  Media   Media_w Media_w_Min_95
#> 1       vs 32 102.952 29.36848       0 0.4375 0.3550975      0.1734364
#>   Media_w_Max_95 Min Q25 Mediana Q75 Max        sd     sd_w     hist
#> 1      0.5367586   0   0       0   1   1 0.5040161 0.480884 ▇▁▁▁▁▁▁▆
#> 
#> $Numericas$am
#>   Variable  N     N_w    N_eff Missing   Media   Media_w Media_w_Min_95
#> 1       am 32 102.952 29.36848       0 0.40625 0.3044428       0.129756
#>   Media_w_Max_95 Min Q25 Mediana Q75 Max        sd      sd_w     hist
#> 1      0.4791297   0   0       0   1   1 0.4989909 0.4624224 ▇▁▁▁▁▁▁▆
#> 
#> $Numericas$gear
#>   Variable  N     N_w    N_eff Missing  Media  Media_w Media_w_Min_95
#> 1     gear 32 102.952 29.36848       0 3.6875 3.560708       3.291738
#>   Media_w_Max_95 Min Q25 Mediana Q75 Max        sd      sd_w     hist
#> 1       3.829678   3   3       4   4   5 0.7378041 0.7120043 ▇▁▁▆▁▁▁▂
#> 
#> $Numericas$carb
#>   Variable  N     N_w    N_eff Missing  Media  Media_w Media_w_Min_95
#> 1     carb 32 102.952 29.36848       0 2.8125 3.015988       2.422692
#>   Media_w_Max_95 Min Q25 Mediana Q75 Max     sd     sd_w     hist
#> 1       3.609284   1   2       2   4   8 1.6152 1.570544 ▆▇▂▇▁▁▁▁
#> 
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
#> Joining with `by = join_by(gear, cyl)`
#> Descriptivos agrupados categóricos generados
#> Joining with `by = join_by(gear)`
#> Joining with `by = join_by(gear)`
#> Descriptivos agrupados numéricos generados
print(resultados_agrupados)
#> $Numericas
#> $Numericas$mpg
#> # A tibble: 3 × 18
#>    gear Variable     N   N_w N_eff Missing Media Media_w Media_w_Min_95
#>   <dbl> <chr>    <int> <dbl> <dbl>   <int> <dbl>   <dbl>          <dbl>
#> 1     3 mpg         15  58.4 14.4        0  16.1    15.6           13.7
#> 2     4 mpg         12  31.4 11.4        0  24.5    23.6           20.4
#> 3     5 mpg          5  13.2  4.64       0  21.4    19.7           12.2
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd_w <dbl>, hist <chr>
#> 
#> $Numericas$hp
#> # A tibble: 3 × 18
#>    gear Variable     N   N_w N_eff Missing Media Media_w Media_w_Min_95
#>   <dbl> <chr>    <int> <dbl> <dbl>   <int> <dbl>   <dbl>          <dbl>
#> 1     3 hp          15  58.4 14.4        0 176.    182.           157. 
#> 2     4 hp          12  31.4 11.4        0  89.5    93.7           77.4
#> 3     5 hp           5  13.2  4.64       0 196.    219.            90.5
#> # ℹ 9 more variables: Media_w_Max_95 <dbl>, Min <dbl>, Q25 <dbl>,
#> #   Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd_w <dbl>, hist <chr>
#> 
#> 
#> $Categoricas
#> $Categoricas$cyl
#> # A tibble: 3 × 19
#>   cyl    `3_p`  `4_p` `5_p` `3_p_Min_95` `4_p_Min_95` `5_p_Min_95` `3_p_Max_95`
#>   <chr>  <dbl>  <dbl> <dbl>        <dbl>        <dbl>        <dbl>        <dbl>
#> 1 8     0.842  NA     0.508       0.728        NA           0.268         0.914
#> 2 4     0.0428  0.605 0.280       0.0134        0.432       0.111         0.129
#> 3 6     0.115   0.395 0.212       0.0558        0.245       0.0724        0.221
#> # ℹ 11 more variables: `4_p_Max_95` <dbl>, `5_p_Max_95` <dbl>, `3_n` <dbl>,
#> #   `4_n` <dbl>, `5_n` <dbl>, `3_n_sinW` <int>, `4_n_sinW` <int>,
#> #   `5_n_sinW` <int>, `3_sd` <dbl>, `4_sd` <dbl>, `5_sd` <dbl>
#> 
#> 
#> attr(,"vars_grupo")
#> [1] TRUE
#> attr(,"peso")
#> [1] TRUE


resultados_agrupados_automaticos <- generar_descriptivos_agrupados( 
  datos = mtcars,
  vars_grupo = 'cyl'
  )
#> Descriptivos agrupados numéricos generados

# Formatear los descriptivos univariados para exportar a Excel
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
