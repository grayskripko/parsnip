# parsnip 0.0.0.9000

* The `fit` interface was previously used to cover both the x/y interface as well as the formula interface. Now, `fit` is the formula interface and [`fit_xy` is for the x/y interface](https://github.com/topepo/parsnip/issues/33). 
* Added a `NEWS.md` file to track changes to the package.
* `predict` methods were [overhauled](https://github.com/topepo/parsnip/issues/34) to be [consistent](https://github.com/topepo/parsnip/issues/41).
* MARS was added. 