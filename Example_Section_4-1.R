## Low-dimensional settings:
## Comparison of GRPtest with Hosmer-Lemeshow tests (from package MKmisc)

library(MASS)
library(glmnet)
library(randomForest)
library(MKmisc)
library(ranger)
#library(GRPtests)

gen.data.f <- function(n, p, fam, ids, sig){
  s <- 3
  beta <- c(rep(1, min(p,s)), rep(0, p - min(p,s)))    # parameters
  sigma0 <- toeplitz(rho^(0:(p-1)))
  
  X <- mvrnorm(n, rep(0,p), sigma0)*1
  f = sig * X[, ids[1]] * X[, ids[2]]
  z = f + crossprod(t(X), beta) 
  
  if(fam == "gaussian"){
    y = z + rnorm(n)
  }else{
    pr = 1/(1 + exp(-z)) 
    y = rbinom(n, 1, pr)      
  }
  
  return(list(X = X, y = y))
}


#####################################################
## SETTINGS:
#####################################################

n <- 300                        # sample size
p <- 10                         # number of parameters
fam <- "binomial"

iter <- 200

sigs <- seq(0, by = 0.2, 2)
scenarios <- cbind(c(1,1),c(5,5),c(1,2),c(1,3),c(1,4),c(4,7))

pvals <- pvalsHLC <- pvalsHLH2 <- pvalsHLH <- pvalsLCS <- array(0, dim=c(ncol(scenarios), length(sigs), iter))

rhos <- 0.6 #seq(0.4, 0.8, by = 0.2)

#####################################################
##  EXPERIMENT:
#####################################################

set.seed(12)

for(j in 1:ncol(scenarios)){
  ids <- scenarios[,j]
  
  for(k in 1:length(sigs)){
    print(k)
    
    sig <- sigs[k]
    rho <- rhos
    
    for(i in 1:iter){
      cat(paste(i," "))

      gd <- gen.data.f(n, p, fam, ids, sig)
      X <- gd$X
      y <- gd$y
      
      ## HL tests
      fit <- glm(y ~ X, family = binomial)
      obj <- HLgof.test(fit = fitted(fit), y, X = model.matrix(y ~ X))
      
      pvalsHLH[j,k,i] <- obj[[1]]$p.value
      pvalsHLC[j,k,i] <- obj[[2]]$p.value
      pvalsLCS[j,k,i] <- obj[[3]]$p.value
      
      pvals[j,k,i] <- GRPtest(X, y, fam = "binomial", penalize = FALSE, nsplits = 1)

    }
    
  }
}


#####################################################
### POWER PLOTS
#####################################################

# function to calculate power
calc_pow <- function(pv){
  apply(pv, 1, function(x) mean(x < 0.05))
}

# function to plot power
plot_power <- function(li, scen){
  
  pvals <- li[[1]][scen,,]
  pvalsHLC <- li[[2]][scen,,]
  pvalsHLH <- li[[3]][scen,,]
  pvalsLCS <- li[[4]][scen,,]
  
  pow <- calc_pow(pvals)
  powHLC <- calc_pow(pvalsHLC)
  powHLH <- calc_pow(pvalsHLH)
  powLCS <- calc_pow(pvalsLCS)  
  
  plot(sigs, pow,xlim=c(0,sigs[length(sigs)]),ylim=c(0,1),col=cols[1],
       xlab= expression(sigma),
       ylab = "Probability of rejection",
       # main=paste("Power comparison","\n","p =",p, ", n =",n),
       pch = 19)
  lines(sigs, pow,  col = cols[1], lwd = 2)
  lines(sigs, powHLC, col = cols[2], lwd = 2)
  points(sigs,powHLC, col = cols[2], pch =19)
  lines(sigs, powHLH, col = cols[3], lwd = 2)
  points(sigs,powHLH, col = cols[3],pch = 19)
  lines(sigs, powLCS, col = cols[4], lwd = 2)
  points(sigs,powLCS, col = cols[4], pch =19)
  legend("topleft",inset=.02,nams,col=cols,bty = "n",cex=1,pch=c(19,19,19,19),
         lty=c(1,1,1,1),lwd=c(2,2,2,2))
  
}

#titl <- ifelse(H0 == TRUE, "H0 true,", "H1 true,")
cols <- c("red","black","blue","violet")
nams <- c("RP-test",
          expression(paste("Hosmer-Lemeshow ",hat(C))),
          expression(paste("Hosmer-Lemeshow ",hat(H))),
          "le Cessie et al.")

li <- list(pvals,pvalsHLC,pvalsHLH, pvalsLCS)


## FINAL PLOTS:

par(mfrow=c(2,3))
plot_power(li, 1)
plot_power(li, 2)
plot_power(li, 3)
plot_power(li, 4)
plot_power(li, 5)
plot_power(li, 6)


