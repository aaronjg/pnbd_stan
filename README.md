Pareto/NBD Model implemented in Stan
-----

[Model writeup](https://rawgit.com/aaronjg/pnbd_stan/master/pnbd.html)

This is an implementation of the Pareto/NBD model in Stan. The Pareto/NBD model is a latent attrition model of customer lifetime value developed for non-contractual purchases [1]. In this model the individual level purchase rate is governed by a Poisson process, customer lifetimes are exponentially distributed, and heterogeneity of customer purchase and death rates are modeled by gamma distributions.

A clear note on deriving the Pareto/NBD has been written by Fader & Hardie, and is used as the basis for this model [2].

This model was presented by Aaron Goodman at the March 27th meeting of the Stanford Stan Users group, and a follow up meeting at the August 6th user group.



[1] Schmittlein, D. C., Morrison, D. G., & Colombo, R. (1987). Counting Your Customers: Who-Are They and What Will They Do Next? Management Science, 33(1), 1–24. http://doi.org/10.1287/mnsc.33.1.1

[2] Fader, P. S. & Hardie, B. G. S. (2005). A Note on Deriving the Pareto/NBD Model and Related Expressions. http://www.brucehardie.com/notes/009/


Code © 2018, Aaron Goodman, licensed under GPL 3.
