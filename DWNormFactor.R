DWNormFactor <-function (obs, ref, libsize.obs = NULL, libsize.ref = NULL, 
                         logratioTrim = 0.3, sumTrim = 0.05, doWeighting = TRUE, 
                         Acutoff = -1e+10, optimal = TRUE) 
{
  obs <- as.numeric(obs)
  ref <- as.numeric(ref)
  if (is.null(libsize.obs)) 
    nO <- sum(obs)
  else nO <- libsize.obs
  if (is.null(libsize.ref)) 
    nR <- sum(ref)
  else nR <- libsize.ref
  logR <- log2((obs/nO)/(ref/nR))
  absE <- (log2(obs/nO) + log2(ref/nR))/2
  v <- (nO - obs)/nO/obs + (nR - ref)/nR/ref
  fin <- is.finite(logR) & is.finite(absE) & (absE > Acutoff)
  logR <- logR[fin]
  absE <- absE[fin]
  v <- v[fin]
  if (max(abs(logR)) < 1e-06) 
    return(1)
  n <- length(logR)
  
  # old code
  # if (optimal) {
  #   # with optimal alpha
  #   logratioTrim  <- OptAlpah(logR)
  #   # print(logratioTrim)
  #   loL <- floor(n * logratioTrim) + 1
  #   hiL <- n + 1 - loL
  #   sumTrim  <- OptAlpah(absE)
  #   loS <- floor(n * sumTrim) + 1
  #   hiS <- n + 1 - loS
  #   # print(sumTrim)
  # } else {
  #   # without optimal alpha
  #   loL <- floor(n * logratioTrim) + 1
  #   hiL <- n + 1 - loL
  #   loS <- floor(n * sumTrim) + 1
  #   hiS <- n + 1 - loS
  # }

  
  # new code
  for (eta in seq(0.001, 0.0001, -0.0001)) {
    if (is.finite(logratioTrim  <- lOptAlpah(logR, eta))){
      break
    }
  }
  loL <- floor(n * logratioTrim) + 1
  # hiL <- n  - floor(n * logratioTrim)
  hiL <- n + 1 - loL
  # par(new=TRUE)
# print(logratioTrim)
  # cat(eta, logratioTrim)

  for (eta in seq(0.001, 0.0001, -0.0001)) {
    if (is.finite(sumTrim  <- SOptAlpah(absE, eta))){
      break
    }
  }
# print(sumTrim)
  loS <- floor(n * sumTrim) + 1
  # hiS <- n - loS
  hiS <- n + 1 - loS

  keep <- (rank(logR) >= loL & rank(logR) <= hiL) & (rank(absE) >= 
                                                       loS & rank(absE) <= hiS)
  if (doWeighting) 
    f <- sum(logR[keep]/v[keep], na.rm = TRUE)/sum(1/v[keep], 
                                                   na.rm = TRUE)
  else f <- mean(logR[keep], na.rm = TRUE)
  if (is.na(f)) 
    f <- 0
  2^f
}
