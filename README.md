# GRPtests
Goodness-of-fit testing in high-dimensional generalized linear models

The code in this repository reproduces empirical results from Section 4 of [Janková, J., Shah, R. D., Bühlmann, P. and Samworth, R. J., Goodness-of-fit testing in high-dimensional generalized linear models (2020), ArXiv: 1908.03606](https://arxiv.org/abs/1908.03606).<br/><br/>
The codes (implemented in R) are available in <br/><br/>
[Example_Section_4-1](https://github.com/jankova/GRPtests/blob/master/Example_Section_4-1.R),<br/>
[Example_Section_4-2](https://github.com/jankova/GRPtests/blob/master/Example_Section_4-1.R),<br/>
[Example_Section_4-3](https://github.com/jankova/GRPtests/blob/master/Example_Section_4-1.R),<br/>
[Example_Section_4-4](https://github.com/jankova/GRPtests/blob/master/Example_Section_4-1.R).<br/>

The R package <b> GRPtests </b> can be installed through R:
```
install.packages("GRPtests")
library(GRPtests)
```

A minimalistic example for testing goodness-of-fit in logistic regression:

```
set.seed(1)
X <- matrix(rnorm(300*30), 300, 30)
z <- X[, 1] + X[, 2]^4
pr <- 1/(1 + exp(-z))
y <- rbinom(nrow(X), 1, pr)
(out <- GRPtest(X, y, fam = "binomial", nsplits = 5))
```
