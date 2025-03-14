

# TITULO - NOTA -----------------------------------------------------------

add_titleNote <- function(t,titulo='',nota=''){

  t <- ungroup(t)

  if(titulo!=''){

    z <- rep(NA, nrow(t))
    z[1] <- titulo

    t <- t %>% mutate('Titulo'= z, .before = 1 )
    attr(t,'Titulo') <- titulo
  }

  if( nota != '' ){
    nota <- ifelse(nota=='',nota,paste0('Nota: ',nota))
    t <- t %>% bind_rows(tibble('Titulo'=nota))
    attr(t,'Nota') <- nota
  }
  t
}

# attr(t,'')
#
# temp <- add_titleNote(mtcars,'Hola')
# attributes(temp)
# attributes(temp)$Nota
#
# if(!is.null(attributes(temp)$Titulo)){
#   # le quito el titulo en la primera fila de la 1a columna y se lo pongo como nombre de variable
#   temp[1,1] <- NA
#   colnames(temp)[1] <- attributes(temp)$Titulo
#
# }
#
# ajustar_tibble(temp) |> attributes()

percent <- function(x,accuracy=1,...){
  scales::percent(x=x,accuracy=accuracy,big.mark = '.',decimal.mark = ',',...)
}

number <- function(x,accuracy=.1,...){
  scales::number(x=x,accuracy=accuracy,big.mark = '.',decimal.mark = ',',...)
}
convert_p_num <- function(x){
  out <- gsub('%','',x)
  out <-  gsub(',','.',out)
  as.numeric(out)
}

sd_pond <- function(x,w){
  NA_ind <- which( is.na(x) )
  x <- x[-NA_ind]
  w <- w[-NA_ind]
  # Calcular la media ponderada
  w_sum <- sum(w)
  # if (w_sum == 0) {
  #   stop("La suma de los pesos w es cero; no se puede calcular la desviación estándar ponderada.")
  # }
  w_mean <- sum(w * x) / w_sum

  # Calcular la varianza ponderada (Bessel's correction habitual con sum(w) - 1)
  var_weighted <- sum(w * (x - w_mean)^2) / (w_sum - 1)

  # Retornar la raíz cuadrada de la varianza ponderada
  sqrt(var_weighted)
}

# Intervalo de Wilson o de Agresti-Coull: Estos métodos corrigen algunas deficiencias del intervalo Wald
# y suelen tener un mejor desempeño en términos de cobertura, especialmente en muestras pequeñas o cuando p está cerca de los límites.
ci_margenError_pWilson <- function(p, N, conf_level=0.95, which=c('Min','Max')){
  # obtener el valor crítico a partir de una distribucion normal
  z = qnorm(1 - (1 - conf_level) / 2)

  purrr::map2_dbl(
    p,
    N,
    function(p.i,N.i){
      denominador = (1 + (z^2 / N.i))
      numerador_1 = p.i + (z^2 / (2 * N.i) )
      numerador_2 = z * sqrt((p.i * (1 - p.i) / N.i) + (z^2 / (4 * N.i^2)))
      ifelse(
        which == 'Min',
        (numerador_1-numerador_2)/denominador,
        (numerador_1+numerador_2)/denominador
      )
    }
  )
}

margenError_num <- function(N, sd, conf_level=0.95){

  purrr::map2_dbl(
    N,
    sd,
    function(N.i,sd.i){
      qt(1 - ((1 - conf_level) / 2), N.i - 1) * sd.i / sqrt(N.i)

    }
  )
}

# mtcars %>%
#   group_by(cyl) %>%
#   count(vs) %>%
#   mutate(
#     'N'=sum(n),
#     'p' = n/N,
#     'p_Min' = margenError_pWilson(p=p,N=N,conf_level = 0.95, which='Min'),
#     'p_Max' = margenError_pWilson(p=p,N=N,conf_level = 0.95, which='Max')
#     )
