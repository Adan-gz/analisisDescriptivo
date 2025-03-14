
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
#> Descriptivos univariados numéricos generados
print(resultados_univ)
#> $Numericas
#>    Variable  N     N_w    N_eff Missing      Media     Media_w Media_w_Min_95
#> 1       mpg 32 102.952 29.36848       0  20.090625  18.5499339     16.4847576
#> 2       cyl 32 102.952 29.36848       0   6.187500   6.5992307      5.9647943
#> 3      disp 32 102.952 29.36848       0 230.721875 263.1467946    215.9697711
#> 4        hp 32 102.952 29.36848       0 146.687500 159.9944052    134.7170244
#> 5      drat 32 102.952 29.36848       0   3.596563   3.4843321      3.2955675
#> 6        wt 32 102.952 29.36848       0   3.217250   3.5055275      3.1321221
#> 7      qsec 32 102.952 29.36848       0  17.848750  17.7567661     17.1027728
#> 8        vs 32 102.952 29.36848       0   0.437500   0.3550975      0.1734364
#> 9        am 32 102.952 29.36848       0   0.406250   0.3044428      0.1297560
#> 10     gear 32 102.952 29.36848       0   3.687500   3.5607079      3.2917377
#> 11     carb 32 102.952 29.36848       0   2.812500   3.0159880      2.4226917
#>    Media_w_Max_95    Min       Q25 Mediana    Q75     Max          sd
#> 1      20.6151103 10.400  15.42500  19.200  22.80  33.900   6.0269481
#> 2       7.2336671  4.000   4.00000   6.000   8.00   8.000   1.7859216
#> 3     310.3238181 71.100 120.82500 196.300 326.00 472.000 123.9386938
#> 4     185.2717859 52.000  96.50000 123.000 180.00 335.000  68.5628685
#> 5       3.6730968  2.760   3.08000   3.695   3.92   4.930   0.5346787
#> 6       3.8789330  1.513   2.58125   3.325   3.61   5.424   0.9784574
#> 7      18.4107593 14.500  16.89250  17.710  18.90  22.900   1.7869432
#> 8       0.5367586  0.000   0.00000   0.000   1.00   1.000   0.5040161
#> 9       0.4791297  0.000   0.00000   0.000   1.00   1.000   0.4989909
#> 10      3.8296781  3.000   3.00000   4.000   4.00   5.000   0.7378041
#> 11      3.6092843  1.000   2.00000   2.000   4.00   8.000   1.6152000
#>           sd_w     hist
#> 1    5.4668309 ▃▇▇▇▃▂▂▂
#> 2    1.6794480 ▆▁▁▃▁▁▁▇
#> 3  124.8846405 ▇▆▁▂▅▃▁▂
#> 4   66.9130092 ▃▇▃▅▂▃▁▁
#> 5    0.4996883 ▃▇▁▅▇▂▁▁
#> 6    0.9884601 ▃▃▃▇▆▁▁▂
#> 7    1.7312180 ▃▂▇▆▃▃▁▁
#> 8    0.4808840 ▇▁▁▁▁▁▁▆
#> 9    0.4624224 ▇▁▁▁▁▁▁▆
#> 10   0.7120043 ▇▁▁▆▁▁▁▂
#> 11   1.5705441 ▆▇▂▇▁▁▁▁
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
print(hoja_excel)
#>                                                                               
#> 1  DESCRIPTIVOS - VARIABLES NUMÉRICAS     <NA> <NA>    <NA>  <NA>         <NA>
#> 2                                         <NA> <NA>    <NA>  <NA>         <NA>
#> 3                                <NA>     <NA> <NA>    <NA>  <NA>         <NA>
#> 4                                <NA>     <NA> <NA>    <NA>  <NA>         <NA>
#> 5                                 cyl Variable    N Missing Media Media_Min_95
#> 6                                 4,0      mpg   11       0  26,7         23,6
#> 7                                 6,0      mpg    7       0  19,7         18,4
#> 8                                 8,0      mpg   14       0  15,1         13,6
#> 9                                 4,0      cyl   11       0   4,0          4,0
#> 10                                6,0      cyl    7       0   6,0          6,0
#> 11                                8,0      cyl   14       0   8,0          8,0
#> 12                                4,0     disp   11       0 105,1         87,1
#> 13                                6,0     disp    7       0 183,3        144,9
#> 14                                8,0     disp   14       0 353,1        314,0
#> 15                                4,0       hp   11       0  82,6         68,6
#> 16                                6,0       hp    7       0 122,3         99,8
#> 17                                8,0       hp   14       0 209,2        179,8
#> 18                                4,0     drat   11       0   4,1          3,8
#> 19                                6,0     drat    7       0   3,6          3,1
#> 20                                8,0     drat   14       0   3,2          3,0
#> 21                                4,0       wt   11       0   2,3          1,9
#> 22                                6,0       wt    7       0   3,1          2,8
#> 23                                8,0       wt   14       0   4,0          3,6
#> 24                                4,0     qsec   11       0  19,1         18,0
#> 25                                6,0     qsec    7       0  18,0         16,4
#> 26                                8,0     qsec   14       0  16,8         16,1
#> 27                                4,0       vs   11       0   0,9          0,7
#> 28                                6,0       vs    7       0   0,6          0,1
#> 29                                8,0       vs   14       0   0,0          0,0
#> 30                                4,0       am   11       0   0,7          0,4
#> 31                                6,0       am    7       0   0,4         -0,1
#> 32                                8,0       am   14       0   0,1         -0,1
#> 33                                4,0     gear   11       0   4,1          3,7
#> 34                                6,0     gear    7       0   3,9          3,2
#> 35                                8,0     gear   14       0   3,3          2,9
#> 36                                4,0     carb   11       0   1,5          1,2
#> 37                                6,0     carb    7       0   3,4          1,8
#> 38                                8,0     carb   14       0   3,5          2,6
#> 39                               <NA>     <NA> <NA>    <NA>  <NA>         <NA>
#> 40                               <NA>     <NA> <NA>    <NA>  <NA>         <NA>
#>                                                              
#> 1          <NA>  <NA>  <NA>    <NA>  <NA>  <NA> <NA>     <NA>
#> 2          <NA>  <NA>  <NA>    <NA>  <NA>  <NA> <NA>     <NA>
#> 3          <NA>  <NA>  <NA>    <NA>  <NA>  <NA> <NA>     <NA>
#> 4          <NA>  <NA>  <NA>    <NA>  <NA>  <NA> <NA>     <NA>
#> 5  Media_Max_95   Min   Q25 Mediana   Q75   Max   sd     hist
#> 6          29,7  21,4  22,8    26,0  30,4  33,9  4,5 ▇▂▂▂▁▃▁▃
#> 7          21,1  17,8  18,6    19,7  21,0  21,4  1,5 ▅▁▁▂▂▁▁▇
#> 8          16,6  10,4  14,4    15,2  16,2  19,2  2,6 ▃▁▂▃▇▂▂▃
#> 9           4,0   4,0   4,0     4,0   4,0   4,0  0,0 ▁▁▁▇▁▁▁▁
#> 10          6,0   6,0   6,0     6,0   6,0   6,0  0,0 ▁▁▁▇▁▁▁▁
#> 11          8,0   8,0   8,0     8,0   8,0   8,0  0,0 ▁▁▁▇▁▁▁▁
#> 12        123,2  71,1  78,8   108,0 120,6 146,7 26,9 ▇▁▂▂▁▆▁▃
#> 13        221,8 145,0 160,0   167,6 196,3 258,0 41,6 ▂▇▁▁▁▂▁▂
#> 14        392,2 275,8 301,8   350,5 390,0 472,0 67,8 ▆▆▁▇▁▂▂▃
#> 15         96,7  52,0  65,5    91,0  96,0 113,0 20,9 ▂▇▁▁▁▇▁▃
#> 16        144,7 105,0 110,0   110,0 123,0 175,0 24,3 ▇▁▃▁▁▁▁▂
#> 17        238,6 150,0 176,2   192,5 241,2 335,0 51,0 ▃▇▃▂▅▁▁▂
#> 18          4,3   3,7   3,8     4,1   4,2   4,9  0,4 ▇▅▇▂▂▁▁▂
#> 19          4,0   2,8   3,4     3,9   3,9   3,9  0,5 ▂▁▂▁▁▂▁▇
#> 20          3,4   2,8   3,1     3,1   3,2   4,2  0,4 ▃▇▆▁▂▂▁▂
#> 21          2,7   1,5   1,9     2,2   2,6   3,2  0,6 ▇▃▇▇▃▁▃▇
#> 22          3,4   2,6   2,8     3,2   3,4   3,5  0,4 ▂▂▂▁▁▂▁▇
#> 23          4,4   3,2   3,5     3,8   4,0   5,4  0,8 ▆▇▆▂▁▁▁▆
#> 24         20,3  16,7  18,6    18,9  19,9  22,9  1,7 ▃▁▇▂▆▁▁▂
#> 25         19,6  15,5  16,7    18,3  19,2  20,2  1,7 ▇▇▇▁▇▇▇▇
#> 26         17,5  14,5  16,1    17,2  17,6  18,0  1,2 ▃▁▂▂▁▆▆▇
#> 27          1,1   0,0   1,0     1,0   1,0   1,0  0,3 ▁▁▁▁▁▁▁▇
#> 28          1,1   0,0   0,0     1,0   1,0   1,0  0,5 ▆▁▁▁▁▁▁▇
#> 29          0,0   0,0   0,0     0,0   0,0   0,0  0,0 ▁▁▁▇▁▁▁▁
#> 30          1,0   0,0   0,5     1,0   1,0   1,0  0,5 ▃▁▁▁▁▁▁▇
#> 31          0,9   0,0   0,0     0,0   1,0   1,0  0,5 ▇▁▁▁▁▁▁▆
#> 32          0,4   0,0   0,0     0,0   0,0   1,0  0,4 ▇▁▁▁▁▁▁▁
#> 33          4,5   3,0   4,0     4,0   4,0   5,0  0,5 ▁▁▁▇▁▁▁▂
#> 34          4,5   3,0   3,5     4,0   4,0   5,0  0,7 ▃▁▁▇▁▁▁▂
#> 35          3,7   3,0   3,0     3,0   3,0   5,0  0,7 ▇▁▁▁▁▁▁▁
#> 36          1,9   1,0   1,0     2,0   2,0   2,0  0,5 ▇▁▁▁▁▁▁▇
#> 37          5,1   1,0   2,5     4,0   4,0   6,0  1,8 ▃▁▁▁▇▁▁▂
#> 38          4,4   2,0   2,2     3,5   4,0   8,0  1,6 ▅▃▇▁▁▁▁▁
#> 39         <NA>  <NA>  <NA>    <NA>  <NA>  <NA> <NA>     <NA>
#> 40         <NA>  <NA>  <NA>    <NA>  <NA>  <NA> <NA>     <NA>
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
