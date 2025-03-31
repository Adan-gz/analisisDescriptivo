
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

Actualmente, una parte de este documento así como la mayor parte de
documentación de las funciones está elaborado principalmente a través
del modelo 03-mini de ChatGPT, por lo que puede haber algún error.
Tampoco se explica, por ahora, con todo detalle las funcionalidades del
paquete. Esta tarea está pendiente de llevarse a cabo.

## Dependencias

Para utilizar este paquete es necesario tener instalados los siguientes
paquetes: `dplyr`, `emmeans`, `magrittr`, `openxlsx`, `purrr`, `rlang`,
`scales`, `skimr`, `stringr`, `tibble`, `tidyr`. Para hacerlo se puede
utilizar la función `install.packages`.

## Objetivo

El objetivo o razón de ser de este paquete es automatizar la tarea de
explotación de datos habitual:

- Descriptivos univariados

- Descriptivos agrupados por una variabel categórica clave: Tratamiento
  vs Control; Territorio; u cualquier otra variable categórica. Además,
  identifica si existen diferencias significativas.

- Descriptivos cuando la variable dependiente o de interés es una
  variable numérica: se extraen estadístics de relación con las otras
  variables numéricas y, si son categóricas, se utiliza la función
  anterior.

Estas son las relaciones bivariadas que pueden analizarse:

- Variable Categórica frente a Variables Categóricas o Variables
  Numéricas

- Variable Numérica frente a Variables Categóricas o Variables Numéricas

## Características

- **Análisis descriptivo univariado para variables categóricas:**
  Calcula frecuencias, porcentajes y sus intervalos de confianza (usando
  el método de Wilson) para variables categóricas (con o sin ponderar).

<!-- -->

- **Análisis descriptivo univariado para variables numéricas:** Obtén
  estadísticas básicas (media, mediana, cuartiles, desviación estándar,
  histograma ) de variables numéricas (con o sin ponderar)..

<!-- -->

- **Análisis descriptivo agrupado:** Genera de forma sencilla
  descriptivos numéricos y categóricos agrupando por las categorías de
  una variable categórica.

<!-- -->

- **Análisis descriptivo para una variable numérica (variable
  dependiente o de interés):** Genera de forma sencilla descriptivos de
  relación respecto a las variables numéricas explicativas y
  estadísticos agrupando por las categorías de una variable categórica.

<!-- -->

- **Análisis descriptivo para una variable categórica (variable
  dependiente o de interés):** Genera de forma sencilla descriptivos de
  relación respecto a las variables numéricas explicativas y
  estadísticos agrupando por las categorías de una variable categórica.
  La principal diferencia respecto al análisis agrupado es que en el
  análisis con las variables categórica se calculan los porcentajes
  agrupando por la variable categórica, en vez de la variable de
  interés.

<!-- -->

- **Exportación a Excel:** Exporta a Excel los resultados ya formateadas
  en una o varias hojas.

## Instalación

Puedes instalar la versión de desarrollo de `analisisDescriptivo` desde
GitHub con:

``` r
# install.packages("remotes")
remotes::install_github("Adan-gz/analisisDescriptivo")
```

## Uso Rápido

Las funciones principales del paquete son:

1.  `generar_descriptivos_univariados`: generar los descriptivos
    univariados de variables categóricas y numéricas. Si no se indican
    cuáles se seleccionan de manera automática.
2.  `generar_descriptivos_agrupados`: calcula estadísticos descriptivos
    de variables categóricas y numéricas según las categorías de la
    variable categórica indicada.
3.  `generar_descriptivos_VDnumerica`: calcula estadísticos de relación
    entre 2 variables numéricas y estadísticis descriptivos de la
    variable numérica según las categorías de las variables categóricas.
4.  `generar_descriptivos_VDcategorica`: calcula estadísticos de
    relación entre 2 variables categóricas (agrupando por la variable
    independiente) y entre la categórica y la numérica.
5.  `crear_Excel`: genera un workbook a través de `openxlsx` y exporta
    el archivo Excel ya formateado.

**Ahora mismo las funciones no están diseñadas para poder pasar más de 1
variable de agrupación**. Podría funcionar, pero el comportamiento es
imprevisto. Si se quiere agrupar por más de 1 variable la estrategia más
sencilla es: crear una nueva variable uniendo los valores de cada fila
de ambas y pasarle a la función esta nueva variable.

A continuación, se muestra un ejemplo básico que ilustra cómo generar
estadísticas descriptivas utilizando el paquete:

``` r

library(analisisDescriptivo)
library(dplyr)
# creamos un tibble temporal a partir de los datos mtcars que vienen por defecto en R
temp <- mtcars %>%
  mutate('cyl'   = as.character(cyl),
         'carb'  = factor(carb),
         'gear'  = factor(gear),
         # una variable para agrupar
         'grupo' = sample(c('Tratamiento','Control'),nrow(.),T),
         # añadimos un vector de pesos
         'pesos'     = rlnorm(32)
         )

# Análisis descriptivo univariado (tanto numérico como categórico)
resultados_univ <- generar_descriptivos_univariados( 
  datos     = temp,
  selecc_vars_auto = TRUE, # dejamos que seleccione las variables automáticamente
  var_peso  = "pesos", # vector para ponderar
  num_unificar_1tabla = TRUE # por defecto devuelve una lista, donde cada elemento son los descriptivos de cada variable. Con este argumento en TRUE devuelve un dataframe con todas las variables juntas, pero sólo para los descriptivos numéricos
)
```

El output obtenido se ve de esta forma en la consola de R:

``` r
print(resultados_univ)
#> $Numericas
#> # A tibble: 9 × 15
#>   Variable     N Missing   Media Media_w Media_w_Min_95 Media_w_Max_95    Min
#>   <chr>    <int>   <int>   <dbl>   <dbl>          <dbl>          <dbl>  <dbl>
#> 1 mpg         32       0  20.1    19.9           17.6           22.2   10.4  
#> 2 disp        32       0 231.    243.           196.           290.    71.1  
#> 3 hp          32       0 147.    156.           126.           187.    52    
#> 4 drat        32       0   3.60    3.61           3.43           3.78   2.76 
#> 5 wt          32       0   3.22    3.26           2.91           3.60   1.51 
#> 6 qsec        32       0  17.8    17.5           16.9           18.2   14.5  
#> 7 vs          32       0   0.438   0.385          0.206          0.563  0    
#> 8 am          32       0   0.406   0.462          0.280          0.645  0    
#> 9 pesos       32       0   1.41    2.22           1.84           2.61   0.125
#> # ℹ 7 more variables: Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>,
#> #   sd_w <dbl>, hist <chr>
#> 
#> $Categoricas
#> $Categoricas$cyl
#>   cyl    n         p   p_Min_95  p_Max_95         sd N_eff n_sinW  p_sinW
#> 1   4 14.9 0.3309268 0.16829009 0.5473086 0.10436578  20.3     11 0.34375
#> 2   6  6.8 0.1499934 0.05278752 0.3584596 0.07919588  20.3      7 0.21875
#> 3   8 23.4 0.5190798 0.31683281 0.7152616 0.11081764  20.3     14 0.43750
#> 
#> $Categoricas$gear
#>   gear    n         p   p_Min_95  p_Max_95        sd N_eff n_sinW  p_sinW
#> 1    3 19.2 0.4255152 0.23988640 0.6348213 0.1096610  20.3     15 0.46875
#> 2    4 18.5 0.4096638 0.22744074 0.6206030 0.1090734  20.3     12 0.37500
#> 3    5  7.4 0.1648209 0.06087804 0.3753106 0.0822908  20.3      5 0.15625
#> 
#> $Categoricas$carb
#>   carb    n          p     p_Min_95  p_Max_95         sd N_eff n_sinW  p_sinW
#> 1    1 11.3 0.24986853 0.1125048309 0.4667441 0.09602400  20.3      7 0.21875
#> 2    2 12.8 0.28238757 0.1342054267 0.4997444 0.09984425  20.3     10 0.31250
#> 3    3  2.0 0.04445877 0.0073434564 0.2263817 0.04571500  20.3      3 0.09375
#> 4    4 14.9 0.32925766 0.1670863895 0.5457046 0.10423201  20.3     10 0.31250
#> 5    6  0.5 0.01087977 0.0005634873 0.1766778 0.02300857  20.3      1 0.03125
#> 6    8  3.8 0.08314770 0.0209252749 0.2778793 0.06123929  20.3      1 0.03125
#> 
#> $Categoricas$grupo
#>         grupo    n         p  p_Min_95  p_Max_95        sd N_eff n_sinW  p_sinW
#> 1     Control 25.6 0.5669377 0.3584702 0.7541270 0.1099001  20.3     17 0.53125
#> 2 Tratamiento 19.6 0.4330623 0.2458730 0.6415298 0.1099001  20.3     15 0.46875
#> 
#> 
#> attr(,"peso")
#> [1] TRUE
```

Y se puede exportar a Excel de esta forma. Así se ha generado en R el
objeto workbook y además se ha exportado el Excel.

``` r
workbook <- crear_Excel( 
  resultados_univ, 
  unificar_misma_hoja = TRUE, 
  titulos_principales = 'DESCRIPTIVOS UNIVARIADOS', 
  exportar            = TRUE, 
  nombre_archivo      = 'Descriptivos_Univariados'
)
```

Así se vería:

![](img/Imagen1.png)

Si queremos obtener los descriptivos agrupados por la variable `grupo`
bastaría con utilizar la función `generar_descriptivos_agrupados`.

En el caso de las variables numéricas, se realiza una regresión OLS y se
incluyen los coeficientes (`Dif_categoriaReferencia`) y el `p.valor`. Si
se ha especificado pesos las regresiones se calculan aplicando la
ponderación. Pero la distribución y cuartiles se calculan sin ponderar.

``` r
# Análisis descriptivo agrupado (tanto numérico como categórico)
resultados_agrupados <- generar_descriptivos_agrupados( 
  datos      = temp,
  # podriamos indicar las variables de intereres con 'vars_categoricas' y 'vars_numericas', pero dejamos que seleccione las variables automáticamente
  vars_grupo = 'grupo',
  var_peso   = "pesos", # vector para ponderar
  num_unificar_1tabla = FALSE # en este caso no queremos que unifique los descriptivos numéricos en 1 tabla
)
print(resultados_agrupados)
#> $Numericas
#> $Numericas$mpg
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    mpg         17       0  19.8    21.1                  NA     NA    
#> 2 Tratamien… mpg         15       0  20.4    18.3                  -2.88   0.217
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$disp
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    disp        17       0  233.    226.                   NA    NA    
#> 2 Tratamien… disp        15       0  228.    266.                   40.5   0.390
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$hp
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    hp          17       0  159.    164.                   NA    NA    
#> 2 Tratamien… hp          15       0  133.    147.                  -17.4   0.568
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$drat
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    drat        17       0  3.59    3.67                 NA      NA    
#> 2 Tratamien… drat        15       0  3.61    3.52                 -0.157   0.375
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$wt
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    wt          17       0  3.22    3.06                 NA      NA    
#> 2 Tratamien… wt          15       0  3.22    3.52                  0.463   0.177
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$qsec
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    qsec        17       0  17.6    17.4                 NA      NA    
#> 2 Tratamien… qsec        15       0  18.2    17.7                  0.298   0.633
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$vs
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    vs          17       0 0.412   0.442                 NA      NA    
#> 2 Tratamien… vs          15       0 0.467   0.309                 -0.133   0.459
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Numericas$am
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    am          17       0 0.412   0.571                 NA      NA    
#> 2 Tratamien… am          15       0 0.4     0.320                 -0.251   0.169
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> 
#> $Categoricas
#> $Categoricas$cyl
#> # A tibble: 3 × 10
#>   cyl   grupo_Control_p grupo_Tratamiento_p Control_n Tratamiento_n
#>   <fct>           <dbl>               <dbl>     <dbl>         <dbl>
#> 1 4              0.422                0.212      10.8           4.1
#> 2 6              0.0787               0.243       2             4.8
#> 3 8              0.499                0.545      12.8          10.7
#> # ℹ 5 more variables: Control_p_sinW <dbl>, Tratamiento_p_sinW <dbl>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> $Categoricas$gear
#> # A tibble: 3 × 10
#>   gear  grupo_Control_p grupo_Tratamiento_p Control_n Tratamiento_n
#>   <fct>           <dbl>               <dbl>     <dbl>         <dbl>
#> 1 3               0.399               0.460      10.2           9  
#> 2 4               0.396               0.428      10.1           8.4
#> 3 5               0.205               0.112       5.2           2.2
#> # ℹ 5 more variables: Control_p_sinW <dbl>, Tratamiento_p_sinW <dbl>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> $Categoricas$carb
#> # A tibble: 6 × 10
#>   carb  grupo_Control_p grupo_Tratamiento_p Control_n Tratamiento_n
#>   <fct>           <dbl>               <dbl>     <dbl>         <dbl>
#> 1 1              0.402               0.0511      10.3           1  
#> 2 2              0.196               0.395        5             7.7
#> 3 3              0.0437              0.0455       1.1           0.9
#> 4 4              0.193               0.508        4.9           9.9
#> 5 6              0.0192             NA            0.5          NA  
#> 6 8              0.147              NA            3.8          NA  
#> # ℹ 5 more variables: Control_p_sinW <dbl>, Tratamiento_p_sinW <dbl>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> 
#> attr(,"vars_grupo")
#> [1] TRUE
#> attr(,"peso")
#> [1] TRUE
```

Y así podríamos añadirlo al workbook existente:

``` r
crear_Excel(
  workbook            = workbook,
  list_list_tablas    = resultados_agrupados,
  unificar_misma_hoja = TRUE, # unificamos 
  nombres_hojas       = 'Hoja_Agrupada', # ponemos nombre a la hoja
  titulos_principales = 'DESCRIPTIVOS AGRUPADOS', 
  exportar            = TRUE,
  nombre_archivo      = 'Descriptivos_Univariados_y_Agrupados'
)
#> A Workbook object.
#>  
#> Worksheets:
#>  Sheet 1: "Hoja 1"
#>  
#> 
#>  Sheet 2: "Hoja_Agrupada"
#>  
#> 
#>  
#>  Worksheet write order: 1, 2
#>  Active Sheet 1: "Hoja 1" 
#>  Position: 1
```

Y este sería el output (se muestra sólo la segunda hoja):

![](img/Imagen2.png)

Únicamente es necesario crear el workbook (`workbook <- crear_Excel()`)
la primera vez. Las siguientes al llamar la función `crear_Excel()` ya
se actualiza el objeto creado de forma automática.

Por último, podrías estar interesados en estudiar como variable
dependiente `mpg`. En este caso se calcula:

- Variable independiente numérica: coeficiente de correlación,
  coeficiente de una regresión lineal y su p.valor (aplicando pesos si
  corresponde), y se trocea la X numérica en cuartiles y se calcula la
  media de la VD para indicar por algún posible patrón no lineal.

- Variable independiente categórica: produce el mismo output que el
  visualizado en la imagen superior.

``` r
resultados_VD_mpg <- generar_descriptivos_VDnumerica(
  temp,
  var_VDnum = 'mpg',
  var_peso  = 'pesos', 
  selecc_vars_auto = TRUE,
  num_unificar_1tabla = T
)
print(resultados_VD_mpg)
#> $Numericas
#> # A tibble: 7 × 12
#>   Var_VD var_X     R2   R2_w OLS_coef OLS_p_value OLS_coef_w OLS_p_value_w
#>   <chr>  <chr>  <dbl>  <dbl>    <dbl>       <dbl>      <dbl>         <dbl>
#> 1 mpg    disp  -0.848 -0.861  -0.0412    9.38e-10    -0.0437      3.09e-11
#> 2 mpg    hp    -0.776 -0.757  -0.0682    1.79e- 7    -0.0600      2.01e- 7
#> 3 mpg    drat   0.681  0.657   7.68      1.78e- 5     8.91        2.50e- 5
#> 4 mpg    wt    -0.868 -0.837  -5.34      1.29e-10    -5.79        4.26e-10
#> 5 mpg    qsec   0.419  0.601   1.41      1.71e- 2     2.32        1.82e- 4
#> 6 mpg    vs     0.664  0.744   7.94      3.42e- 5     9.93        4.30e- 7
#> 7 mpg    am     0.600  0.538   7.24      2.85e- 4     7.00        1.11e- 3
#> # ℹ 4 more variables: Cuartil_1_Media <dbl>, Cuartil_2_Media <dbl>,
#> #   Cuartil_3_Media <dbl>, Cuartil_4_Media <dbl>
#> 
#> $Categoricas
#> $Categoricas$cyl
#> # A tibble: 3 × 18
#>   cyl   Variable     N Missing Media Media_w Dif_categoriaReferencia   p_value
#>   <chr> <chr>    <int>   <int> <dbl>   <dbl>                   <dbl>     <dbl>
#> 1 4     mpg         11       0  26.7    27.5                   NA    NA       
#> 2 6     mpg          7       0  19.7    20.0                   -7.49  1.08e- 4
#> 3 8     mpg         14       0  15.1    15.0                  -12.6   2.06e-11
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Categoricas$gear
#> # A tibble: 3 × 18
#>   gear  Variable     N Missing Media Media_w Dif_categoriaReferencia     p_value
#>   <chr> <chr>    <int>   <int> <dbl>   <dbl>                   <dbl>       <dbl>
#> 1 3     mpg         15       0  16.1    15.3                   NA    NA         
#> 2 4     mpg         12       0  24.5    25.6                   10.3   0.00000127
#> 3 5     mpg          5       0  21.4    17.5                    2.20  0.333     
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Categoricas$carb
#> # A tibble: 6 × 18
#>   carb  Variable     N Missing Media Media_w Dif_categoriaReferencia     p_value
#>   <chr> <chr>    <int>   <int> <dbl>   <dbl>                   <dbl>       <dbl>
#> 1 1     mpg          7       0  25.3    27.8                   NA    NA         
#> 2 2     mpg         10       0  22.4    20.1                   -7.66  0.00138   
#> 3 3     mpg          3       0  16.3    16.3                  -11.4   0.00852   
#> 4 4     mpg         10       0  15.8    15.4                  -12.3   0.00000270
#> 5 6     mpg          1       0  19.7    19.7                   -8.05  0.300     
#> 6 8     mpg          1       0  15      15                    -12.8   0.000367  
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Categoricas$grupo
#> # A tibble: 2 × 18
#>   grupo      Variable     N Missing Media Media_w Dif_categoriaReferen…¹ p_value
#>   <chr>      <chr>    <int>   <int> <dbl>   <dbl>                  <dbl>   <dbl>
#> 1 Control    mpg         17       0  19.8    21.1                  NA     NA    
#> 2 Tratamien… mpg         15       0  20.4    18.3                  -2.88   0.217
#> # ℹ abbreviated name: ¹​Dif_categoriaReferencia
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
```

Estos resultados podrían añadirse al workbook e imprimirse
sobreescribiendo el actual:

``` r
crear_Excel(
  workbook            = workbook,
  list_list_tablas    = resultados_VD_mpg,
  unificar_misma_hoja = TRUE, # unificamos 
  nombres_hojas       = 'Hoja_MPG', # ponemos nombre a la hoja
  titulos_principales = 'DESCRIPTIVOS AGRUPADOS', 
  exportar            = TRUE,
  nombre_archivo      = 'Descriptivos_Univariados_y_Agrupados'
)
#> A Workbook object.
#>  
#> Worksheets:
#>  Sheet 1: "Hoja 1"
#>  
#> 
#>  Sheet 2: "Hoja_Agrupada"
#>  
#> 
#>  Sheet 3: "Hoja_MPG"
#>  
#> 
#>  
#>  Worksheet write order: 1, 2, 3
#>  Active Sheet 1: "Hoja 1" 
#>  Position: 1
```

Así se visualizaría:

![](img/Imagen3.png)

Finalmente, si se tuviera interés en analizar una variable dependiente
categórica, el código sería muy similar.

``` r
resultados_VD_cyl <- generar_descriptivos_VDcategorica(
  temp,
  var_VDcat = 'cyl',
  var_peso  = 'pesos',
  estrategia_valoresPerdidos = 'A',
  selecc_vars_auto = TRUE,
)
print(resultados_VD_cyl)
#> $Numericas
#> # A tibble: 24 × 18
#>    cyl   Variable     N Missing  Media Media_w Dif_categoriaReferencia   p_value
#>    <chr> <chr>    <int>   <int>  <dbl>   <dbl>                   <dbl>     <dbl>
#>  1 4     mpg         11       0  26.7    27.5                    NA    NA       
#>  2 6     mpg          7       0  19.7    20.0                    -7.49  1.08e- 4
#>  3 8     mpg         14       0  15.1    15.0                   -12.6   2.06e-11
#>  4 4     disp        11       0 105.     99.2                    NA    NA       
#>  5 6     disp         7       0 183.    175.                     76.0   1.10e- 2
#>  6 8     disp        14       0 353.    354.                    255.    2.02e-13
#>  7 4     hp          11       0  82.6    72.8                    NA    NA       
#>  8 6     hp           7       0 122.    119.                     46.3   8.82e- 2
#>  9 8     hp          14       0 209.    221.                    148.    1.07e- 8
#> 10 4     drat        11       0   4.07    4.03                   NA    NA       
#> # ℹ 14 more rows
#> # ℹ 10 more variables: Media_w_Min_95 <dbl>, Media_w_Max_95 <dbl>, Min <dbl>,
#> #   Q25 <dbl>, Mediana <dbl>, Q75 <dbl>, Max <dbl>, sd <dbl>, sd.w <dbl>,
#> #   hist <chr>
#> 
#> $Categoricas
#> $Categoricas$gear
#> # A tibble: 3 × 13
#>   cyl   gear_3_p gear_4_p gear_5_p `3_n` `4_n` `5_n` `3_p_sinW` `4_p_sinW`
#>   <fct>    <dbl>    <dbl>    <dbl> <dbl> <dbl> <dbl>      <dbl>      <dbl>
#> 1 4       0.0226    0.717   0.168    0.4  13.3   1.3     0.0667      0.667
#> 2 6       0.0541    0.283   0.0660   1     5.2   0.5     0.133       0.333
#> 3 8       0.923    NA       0.766   17.7  NA     5.7     0.8        NA    
#> # ℹ 4 more variables: `5_p_sinW` <dbl>, Chi2 <dbl>, p_value <dbl>,
#> #   VCramer <dbl>
#> 
#> $Categoricas$carb
#> # A tibble: 3 × 22
#>   cyl   carb_1_p carb_2_p carb_4_p carb_6_p carb_3_p carb_8_p `1_n` `2_n` `4_n`
#>   <fct>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl> <dbl> <dbl> <dbl>
#> 1 4       0.908     0.369   NA           NA       NA       NA  10.2   4.7  NA  
#> 2 6       0.0922   NA        0.353        1       NA       NA   1    NA     5.2
#> 3 8      NA         0.631    0.647       NA        1        1  NA     8.1   9.6
#> # ℹ 12 more variables: `6_n` <dbl>, `3_n` <dbl>, `8_n` <dbl>, `1_p_sinW` <dbl>,
#> #   `2_p_sinW` <dbl>, `4_p_sinW` <dbl>, `6_p_sinW` <dbl>, `3_p_sinW` <dbl>,
#> #   `8_p_sinW` <dbl>, Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
#> 
#> $Categoricas$grupo
#> # A tibble: 3 × 10
#>   cyl   grupo_Control_p grupo_Tratamiento_p Control_n Tratamiento_n
#>   <fct>           <dbl>               <dbl>     <dbl>         <dbl>
#> 1 4              0.422                0.212      10.8           4.1
#> 2 6              0.0787               0.243       2             4.8
#> 3 8              0.499                0.545      12.8          10.7
#> # ℹ 5 more variables: Control_p_sinW <dbl>, Tratamiento_p_sinW <dbl>,
#> #   Chi2 <dbl>, p_value <dbl>, VCramer <dbl>
```

El output se incluiría en el Excel de la misma forma que en los
anteriores casos.

## Detalles

Para conocer mejor los parámetros de las funciones puede consultar la
documentación de cada una, por ejemplo,
`?generar_descriptivos_categoricos`).

## Contribución

¡Las contribuciones, informes de errores y solicitudes de nuevas
funcionalidades son bienvenidos!  
Por favor, abre un issue o envía un pull request en
[GitHub](https://github.com/Adan-gz/analisisDescriptivo).

## Licencia

Este paquete está disponible bajo la Licencia MIT.
