

# GENERAR EXCEL -----------------------------------------------------------

# esta funcion formatea a excel
generar_hojaExcel_descriptivos <- function(
    
  descriptivos_univariados, # list output de generar_descriptivos_univariados(), lista nombrada
  # Numerica
  digits_num = 0.1,
  scale_num  = 1,
  suffix_num = '',
  prefix_num = '',
  style_positive_num = 'none', # scales::number( style_positive = c('none','plus','space') )
  # Categoricas
  digits_fac = 0.1,
  scale_fac = 100,
  suffix_fac = '%',
  style_positive_fac = 'none', # scales::number( style_positive = c('none','plus','space') )
  # Categoricas
  # Comunes
  decimal.mark = ',',
  big.mark = '.'
  
){
  
  univ_num <- descriptivos_univariados$Numericas
  univ_cat <- descriptivos_univariados$Categoricas
  
  is_agrupado <- !is.null( attr( descriptivos_univariados, 'vars_grupo' ) )
  
  if( !is.null( univ_num ) ){
    #como es univariado y no hay grupos unifico en 1 unico dataframe
    univ_num <- purrr::map_df(
      univ_num,
      function(.df){
        .df %>% 
          mutate(
            across(
              c(where(is.numeric),-c(N,Missing)), 
              function(x){
                scales::number(
                  x,accuracy = digits_num, scale = scale_num, 
                  decimal.mark = decimal.mark,big.mark = big.mark,
                  prefix = prefix_num,suffix = suffix_num,
                  style_positive = style_positive_num)   
              }
            )
          ) 
      }
    )
    
    univ_num <- append( 
      list(tibble('DESCRIPTIVOS - VARIABLES NUMÉRICAS'='')),
      list(univ_num)
    ) 
  }
  
  if( !is.null( univ_cat ) ){
    univ_cat <- purrr::map(
      univ_cat,
      function(.df){
        
        if( !is_agrupado ){
          .df %>% 
            mutate( 
              across(
                p:sd, 
                function(x){
                  scales::percent(
                    x,accuracy = digits_fac, scale = scale_fac, 
                    decimal.mark = decimal.mark,big.mark = big.mark,
                    suffix = suffix_fac,
                    style_positive = style_positive_fac)   
                }
              )
            )
        } else {
          .df %>% 
            mutate( 
              across(
                c(ends_with('_p'),contains('_p_'),ends_with('_sd')), 
                function(x){
                  scales::percent(
                    x,accuracy = digits_fac, scale = scale_fac, 
                    decimal.mark = decimal.mark,big.mark = big.mark,
                    suffix = suffix_fac,
                    style_positive = style_positive_fac)   
                }
              )
            )
        }
        
        
      }
    ) 
    
    if(!is.list(univ_cat)) univ_cat <- list(univ_cat)
    
    univ_cat <- append(
      list(tibble('DESCRIPTIVOS - VARIABLES CATEGÓRICAS'='')),
      univ_cat
    ) 
  }
  
  # 'ME FALTAN LAS CATEGORICAS Y LUEGO UNIFICAR AMBAS'
  
  out <- append(univ_num,univ_cat)
  
  concatenar_tibbles( out )
  # out
  
}


# DESCRIPTIVOS AGRUPADOS ---------------------------------------------------


'AÑADIR LOS TEST EN LOS AGRUPADOS!!'


generar_descriptivos_agrupados <- function(
    
  data,
  vars_fac = NULL, # factores
  vars_num = NULL, # numericas
  vars_grupo = NULL, # en principio no lo implemento aqui ya que esto tendra su funcion par alos bivariados
  var_peso = NULL,
  # lump = NULL,
  conf_level = 0.95,
  select_vars_aut = TRUE, # si son NULL vars_fac o vars_num seleccionarlas de forma automatica
  ## categoricas
  pivot = T, # si TRUE pivota a wide la p y la N a las columnas junto con la variable de agrupacion, solo para tibbles agrupadosç
  pivot_var = c('var_grupo','var_fac'),
  estrategia_missings = c('E','A'), # remove (eliminar) o agrupar, por defecto eliminar
  ## Numericas
  digits = .1,
  return_df = F # devolver tibble en el caso de variables numericas
  
){
  # inicializo en NULL las listas de descritivos
  univ_num <- NULL
  univ_fac <- NULL
  # Si no paso variables, las cojo según su clase
  
  if(is.null(vars_num) & select_vars_aut ){
    vars_num <- data %>% select_if(is.numeric) %>% colnames()
  }
  if(is.null(vars_fac) & select_vars_aut){
    vars_fac <- data %>% select_if(\(x)is.character(x)|is.factor(x)) %>% colnames()
  }
  
  if( length(vars_fac) > 0 ){
    univ_fac <- generar_descriptivos_categoricos(
      data = data,
      vars_fac = vars_fac,
      vars_grupo = vars_grupo,
      var_peso = var_peso,
      pivot = pivot,
      pivot_var = pivot_var,
      conf_level = conf_level,
      estrategia_missings = estrategia_missings
    )
    print('Categoricos generados')
    
  } 
  if( length(vars_num) > 0 ){
    univ_num <- generar_descriptivos_numericos(
      data = data,
      vars_num = vars_num,
      vars_grupo = vars_grupo,
      var_peso = var_peso,
      digits = digits,
      conf_level = conf_level,
      return_df = return_df  )
    print('Numericos generados')
  }
  
  # output 
  out <- list(
    'Numericas'     = univ_num,
    'Categoricas'   = univ_fac
  )
  attr(out,'vars_grupo') <- TRUE
  attr(out,'peso') <- !is.null(var_peso)
  out
}




# DESCRIPTIVOS UNIVARIADOS ------------------------------------------------


# temp_univariados <- generar_descriptivos_univariados(data = temp)
# temp_univariados$Categoricas
# generar_report_descriptivos_univariados(temp_univariados)
# conca

# concatenar_tibbles( temp_univariados$Numericas )


generar_descriptivos_univariados <- function(
    
  data,
  vars_fac = NULL, # factores
  vars_num = NULL, # numericas
  # vars_grupo = NULL, # en principio no lo implemento aqui ya que esto tendra su funcion par alos bivariados
  var_peso = NULL,
  # lump = NULL,
  conf_level = 0.95,
  select_vars_aut = TRUE, # si son NULL vars_fac o vars_num seleccionarlas de forma automatica
  ## categoricas
  pivot = T, # si TRUE pivota a wide la p y la N a las columnas junto con la variable de agrupacion, solo para tibbles agrupadosç
  pivot_var = c('var_grupo','var_fac'),
  estrategia_missings = c('E','A'), # remove (eliminar) o agrupar, por defecto eliminar
  ## Numericas
  digits = .1,
  return_df = F # devolver tibble en el caso de variables numericas
  
){
  
  # inicializo en NULL las listas de descritivos
  univ_num <- NULL
  univ_fac <- NULL
  # Si no paso variables, las cojo según su clase
  
  if(is.null(vars_num) & select_vars_aut ){
    vars_num <- data %>% select_if(is.numeric) %>% colnames()
  }
  if(is.null(vars_fac) & select_vars_aut){
    vars_fac <- data %>% select_if(\(x)is.character(x)|is.factor(x)) %>% colnames()
  }

  if( length(vars_fac) > 0 ){
    univ_fac <- generar_descriptivos_categoricos(
      data = data,
      vars_fac = vars_fac,
      var_peso = var_peso,
      pivot = pivot,
      pivot_var = pivot_var,
      conf_level = conf_level,
      estrategia_missings = estrategia_missings
      )
    print('Descriptivos univariados categóricos generados')
    
  } 
  if( length(vars_num) > 0 ){
      univ_num <- generar_descriptivos_numericos(
        data = data,
        vars_num = vars_num,#vars_grupo = vars_grupo,
        var_peso = var_peso,
        digits = digits,
        conf_level = conf_level,
        return_df = return_df  )
      print('Descriptivos univariados numéricos generados')
  }

  # output 
  out <- list(
    'Numericas'     = univ_num,
    'Categoricas' = univ_fac
  )
  attr(out,'peso') <- !is.null(var_peso)
  out
  # attr( output,'vars_num' ) <- if_else( is.null(vars_num)==T, character(),vars_num)
  # attr( output,'vars_fac' ) <- if_else( is.null(vars_fac)==T, character(),vars_fac)
  # attr( output,'group_vars' ) <- group_vars(data)
  # attr( output,'var_peso' ) <- if_else( is.null(var_peso)==T, character(),var_peso)
  # output
}

# generar_descriptivos_univariados( mtcars  )
# generar_descriptivos_univariados( temp  )

## CATEGORICAS -------------------------------------------------------------


generar_DescCat <- function(
    data,
    var_fac,
    vars_grupo = NULL,
    var_peso = NULL,
    # lump = NULL, # numeric vector, proportion to lump, lo dejo por implementar, no es prioritario
    pivot = T, # si TRUE pivota a wide la p y la N a las columnas junto con la variable de agrupacion, solo para tibbles agrupadosç
    pivot_var = c('var_grupo','var_fac'),
    conf_level = 0.95,
    estrategia_missings = c('E','A') # remove (eliminar) o agrupar, por defecto eliminar
){
  if( class(data[[var_fac]]) == 'numeric' ) data[[var_fac]] <- as.character(data[[var_fac]])
  # if( !is.null(lump) & is.numeric(lump) & length(lump) == 1 ){
  #   if( is.null(var_peso) ){
  #     data[[var_fac]] <- forcats::fct_lump_prop(data[[var_fac]],prop = lump,other_level = 'Categorías agrupadas')
  #     
  #   } else {
  #     w_sym <- sym(var_peso)
  #     data <- data %>% 
  #       mutate(
  #         !!as_label(var_fac) :=forcats::fct_lump_prop(data[[var_fac]],prop = lump,w =!!w_sym,other_level = 'Categorías agrupadas')
  #       )
  #   }
  # }
  # }
  
  if( is.grouped_df(data) ) vars_grupo <- group_vars(data)
  
  if(!is.null(vars_grupo)){
    data <- data %>% group_by(!!!syms(vars_grupo))
    # if( var_fac == vars_grupo[1] ){ #si se agrupa por 2 ya no importaría
    #   warning('La variable de agrupar y categórica no puede ser la misma')
    #   return(NULL)
    # }
  } 
  # print(vars_grupo)
  
  var_sym <- sym(var_fac)

  if( is.null(var_peso) ){ # si no hay pesos hacemos recuento normal
    out <- data %>% count( !!var_sym ) 
  } else { # si lo hay ponderamos
    w_sym <- sym(var_peso)
    out <- data %>% count( !!var_sym, wt = !!w_sym ) %>% mutate('n'=round(n,1))
    # añado n sin ponderar
    out <- out %>%
      left_join( data %>% count( !!var_sym, name = 'n_sinW') )
  } 
  # si no hay ningun missing calculamos la p
  is_anyMissing <- any(is.na(data[[var_fac]]))
  if( !is_anyMissing ){
    out <- out %>% mutate('p'=n/sum(n))
  } else { # si lo hubiera entonces aplicaos la estratega seleccionada
    estrategia_missings <- match.arg(estrategia_missings)
    
    if( estrategia_missings == 'E' ){
      # warning('Missings eliminados. No se contabilizan en los porcentajes')
      out <- out %>% filter( !is.na( !!var_sym ) ) %>% mutate('p'=n/sum(n))
    } else if( estrategia_missings == 'A' ){
      # warning('Missings agrupados bajo la categoría NS/NC')
      out[[var_fac]] <- if_else( is.na(out[[var_fac]]) == T, 'NS/NC',out[[var_fac]] )
      out <- out %>% mutate('p'=n/sum(n))
      
    }
  }

    
  if(is.character(data[[var_fac]])){
    out <- out %>% arrange(desc(p))
  } else {
    out <- out %>% arrange(!!sym(var_fac))
    
  }
  
  # añadimos los intervalos
  out <- out %>%  
      mutate(
        'N' = sum(n),
        'sd' = sqrt( p*(1-p)/N ), # el IC no es del toto correcto, pero por ahora lo dejaré así
        # 'p_Min' = p - qt(1 - ((1 - conf_level) / 2), N - 1) * sd ,
        # 'p_Max' = p + qt(1 - ((1 - conf_level) / 2), N - 1) * sd ,
        # Intervalo de Wilson
        'p_Min' = ci_margenError_pWilson(p=p,N=N,conf_level = conf_level, which='Min'),
        'p_Max' = ci_margenError_pWilson(p=p,N=N,conf_level = conf_level, which='Max'),
        .after = p
      ) %>% 
    select(-N) %>%
    # relocate(N,.after=n) %>% 
    relocate(sd,.after=p_Max)
    
  if(pivot & is.grouped_df(data) ){
    pivot_var <- match.arg(pivot_var)
    if( pivot_var != 'var_grupo' ) pivot_var <- var_fac
    else pivot_var <- vars_grupo
    
    # values_var <- if_else(
    #   pivot_var == 'var_grupo',
    #   c('p','p_Min','p_Max','n','N','sd'),
    #   c('p','p_Min','p_Max','n','sd' # quito N)
    # )
    values_var <- c('p','p_Min','p_Max','n','n_sinW','sd')
    
    out <- out %>% 
      ungroup() %>% 
      tidyr::pivot_wider(
        names_from  = all_of(pivot_var),
        values_from = any_of(values_var),
        names_glue = '{.name}_{.value}',
        # names_vary = 'slowest'
      )
    #pivot_wider tiene un comportamiento erratico y si pongo solo {.name} en glue,
    # a veces me pone el value al principio y otras al final, asi que añad esta linea
    # para que me elimine el value del comienzo y aparezca solo al final
    colnames(out) <- gsub( '^p_Min_|^p_Max_|^sd_|^n_|^p_|^N_|^n_sinW_','', colnames(out))
  }
 chr_conf_level <- as.character(stringr::str_split_i(conf_level,'\\.',2))
 # añado al nombr el conf_level utilizado
  out <- out %>% 
    rename_with(
      .cols =  contains(c('_Min','_Max')),#ends_with(c('_Min','_Max')),
      .fn = \(x) paste0(x,'_',chr_conf_level)
      )
  
  out
}

# generar_DescCat(mtcars,'cyl',lump = 0.4)
# temp %>% 
#   group_by(cyl) %>%
#   generar_DescCat('vs','w')

generar_descriptivos_categoricos <- function(
    data,
    vars_fac=NULL,
    vars_grupo = NULL,
    # lump = NULL, # numeric vector, proportion to lump, si longitud 1 se aplica a todos, sino, itera
    var_peso = NULL, # numeric vector
    pivot = T, # si TRUE pivota a wide la p y la N a las columnas junto con la variable de agrupacion, solo para tibbles agrupadosç
    pivot_var = c('var_grupo','var_fac'),
    conf_level = 0.95,
    estrategia_missings = c('E','A'), # remove (eliminar) o agrupar, por defecto eliminar
    select_vars_aut = TRUE # si son NULL vars_fac o vars_num seleccionarlas de forma automatica
){
  
  if(is.null(vars_fac) & select_vars_aut){
    vars_fac <- data %>% select_if(\(x)is.character(x)|is.factor(x)) %>% colnames()
  }
  
  if( any( vars_fac %in% vars_grupo)  ){
    warning("Variable de agrupamiento coincide con variable categórica. Se elimina la segunda")
    vars_fac <- vars_fac[ !vars_fac %in% vars_grupo ]
  }
  # if(is.null(lump)){
    out <- purrr::map(
      vars_fac, 
      \(var_fac.i) generar_DescCat( 
        data = data, 
        var_fac = var_fac.i, 
        vars_grupo = vars_grupo, 
        var_peso = var_peso, 
        pivot = pivot,
        pivot_var = pivot_var,
        conf_level = conf_level,
        estrategia_missings = estrategia_missings  )
    )
  # } else {
    
    # if(length(lump) == 1 ) lump <- rep(lump,length(vars_fac))
    
  #   out <- purrr::map(
  #     vars_fac, #lump,
  #     # \(var_fac.i, lump.i)
  #     \(var_fac.i) generar_DescCat( data = data, var_fac = var_fac.i,, var_peso = var_peso )# lump = lump.i  ) 
  #   ) 
  # }
  out %>% purrr::set_names(vars_fac)
}
# generar_descriptivos_categoricos(mtcars,c('cyl','vs')) -> temps_fac

# concatenar_tibbles(temps_fac,ajustarProporciones = 'p')


## NUMERICAS ---------------------------------------------------------------

generar_DescNum <- function(
    data,
    var_num,
    vars_grupo = NULL,
    var_peso = NULL,
    digits = .1,
    conf_level = .95
    # formatNum = F
){
  # ajustamos la clase de la var_num
  if( class(data[[var_num]]) != 'numeric' ) data[[var_num]] <- as.numeric(data[[var_num]])
  # ajustamos el vector de var_peso

  if(!is.null(var_peso)){ w_sym <- sym(var_peso) }
  # si el tibble viene agrupado, lo desagrupamos para añadir los var_peso y volvemos a agrupar
  # if( is.grouped_df(data) ){
  #   group_vars <- group_vars(data)
  #   data <- ungroup(data) %>% 
  #     mutate('w' = w) %>% 
  #     group_by(!!sym(group_vars))
  # } else {
  #   data <- data %>% mutate('w' = w)
  # }
  if(!is.null(vars_grupo)) data <- data %>% group_by(!!!syms(vars_grupo))
  
  var_sym <- sym(var_num)
  
  out <- data %>% 
    dplyr::summarise(
      Variable = var_num, 
      N = skimr::n_complete(!!var_sym), 
      Missing = skimr::n_missing(!!var_sym), 
      Media = mean(!!var_sym, na.rm = T),
      Min = min(!!var_sym, na.rm = T), 
      Q25 = quantile(!!var_sym, 0.25, na.rm = TRUE), 
      Mediana = median(!!var_sym, na.rm = T), 
      Q75 = quantile(!!var_sym, 0.75, na.rm = TRUE), 
      Max = max(!!var_sym, na.rm = T), 
      sd = sd(!!var_sym, na.rm = T), 
      hist = skimr::inline_hist(!!var_sym),
      .groups = "drop") 
  
  if( is.null(var_peso) ){
    
    out <- out %>%  
      mutate(
        'Media_Min' = Media - margenError_num( N = N, sd = sd, conf_level = conf_level ),#qt(1 - ((1 - conf_level) / 2), N - 1) * sd / sqrt(N),
        'Media_Max' = Media + margenError_num( N = N, sd = sd, conf_level = conf_level ),#qt(1 - ((1 - conf_level) / 2), N - 1) * sd / sqrt(N),
        .after = Media
      )
    
  } else {
    out.w <- data %>% 
      filter( !is.na(!!var_sym) ) %>% 
      summarise(
        'N.w' = sum(!!w_sym, na.rm = TRUE), #tamaño muestra ponderada
        # tamaño muestral efectivo (N.eff)
        'N.eff' = (sum(!!w_sym, na.rm = TRUE)^2) / sum((!!w_sym)^2, na.rm = TRUE),
        'Media.w' = weighted.mean(!!var_sym,w = !!w_sym, na.rm = T),
        'sd.w' = sqrt( Hmisc::wtd.var(!!var_sym,weights = !!w_sym, na.rm = T) ),
      ) 
    # Se une la información, considerando si data está agrupado o no

    if( is.grouped_df(data) ){
      out <- out %>% left_join(out.w)
    } else{
      out <- out %>% bind_cols(out.w)
    }
    
    out <- out %>% 
      mutate(
        'Media.w_Min'  = Media.w - margenError_num( N = N.eff, sd = sd.w, conf_level = conf_level ), #qt(1 - ((1 - conf_level) / 2), N.eff - 1) * sd.w / sqrt(N.eff),
        'Media.w_Max'  = Media.w + margenError_num( N = N.eff, sd = sd.w, conf_level = conf_level ), #qt(1 - ((1 - conf_level) / 2), N.eff - 1) * sd.w / sqrt(N.eff),
      ) %>% 
      relocate(N.w,N.eff,.after = N) %>% 
      relocate( Media.w, Media.w_Min, Media.w_Max, .after = Media ) %>% 
      relocate(sd.w, .after = sd)
  }
  out <- out %>% rename_with(.cols = ends_with(c('_Min','_Max')),
                             .fn = \(x) paste0(x,'_',as.character(stringr::str_split_i(conf_level,'\\.',2))) )

  # if( formatNum ){
  #   return(
  #     out %>% 
  #       mutate(across(c(where(is.numeric),-c(N,Missing)), function(x) number(x, digits))) 
  #   )
  # }
  out
}


generar_descriptivos_numericos <- function(
    data,
    vars_num =NULL,
    vars_grupo = NULL,
    var_peso    = NULL,
    digits = .1,
    conf_level = .95,
    return_df = F,
    select_vars_aut = TRUE # si son NULL, vars_num seleccionarlas de forma automatica
    # se le puede pasar un tibble agrupado o bien agrupar via la funcion
){

  if(is.null(vars_num) & select_vars_aut ){
    vars_num <- data %>% select_if(is.numeric) %>% colnames()
  }
  
  out <- map(
    vars_num,
    \(var_num.i) generar_DescNum( data = data, var_num = var_num.i, vars_grupo = vars_grupo, var_peso = var_peso, digits = digits, conf_level = conf_level )
  ) %>% set_names(vars_num)
  if( return_df ){
    return( bind_rows(out) ) 
  }
  out
}

# temp %>% 
  # group_by(cyl) %>% 
  # generar_descriptivos_numericos( c('mpg','vs') )
  # generar_descriptivos_numericos( c('mpg','vs'), var_peso = 'w' )


