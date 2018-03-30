Pareto/NBD Model implemented in Stan
-----

This is an implementation of the Pareto/NBD model in Stan. The Pareto/NBD model is a latent attrition model of customer lifetime value developed for non-contractual purchases [1]. In this model the individual level purchase rate is governed by a Poisson process, customer lifetimes are exponentially distributed, and heterogeneity of customer purchase and death rates are modeled by gamma distributions.

A clear note on deriving the Pareto/NBD has been written by Fader & Hardie, and is used as the basis for this model [2].

This model was presented by Aaron Goodman at the March 27th meeting of the Stanford Stan Users group. This code is presented as is.

Several models are presented:
* pnbd.stan: The basic Pareto/NBD
* pnbd2.stan: A centered version of the Pareto/NBD
* pnbd3.stan: A variation of the Pareto/NBD with heterogeneity distributed with a log normal, rather than gamma distribution.
* pnbd4.stan: Another variation of the centered version, which does not seem to converge for some reason that we have not determined.

The conclusion from the user group discussion is that the centered pnbd2.stan appears to converge better than pnbd.stan, though still converges slowly. This is likely due to an identifiability issue with the shape and scale parameter of the gamma distribution. This could potentially be fixed with an alternative parameterization to make these parameters less intertwined.

The log normal formulation, pnbd3.stan, does not appear to fit well because it does not allow latent purchase rates near zero.



[1] Schmittlein, D. C., Morrison, D. G., & Colombo, R. (1987). Counting Your Customers: Who-Are They and What Will They Do Next? Management Science, 33(1), 1–24. http://doi.org/10.1287/mnsc.33.1.1

[2] Fader, P. S. & Hardie, B. G. S. (2005). A Note on Deriving the Pareto/NBD Model and Related Expressions. http://www.brucehardie.com/notes/009/


Code © 2018, Aaron Goodman, licensed under GPL 3.
