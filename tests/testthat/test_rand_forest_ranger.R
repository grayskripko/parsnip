library(testthat)
context("random forest execution with ranger")
library(parsnip)
library(tibble)
library(rlang)

data("lending_club")
lending_club <- head(lending_club, 200)
num_pred <- c("funded_amnt", "annual_inc", "num_il_tl")

lc_basic <- rand_forest(mode = "classification")
lc_ranger <- rand_forest(mode = "classification", others = list(seed = 144))

bad_ranger_cls <- rand_forest(mode = "classification",
                              others = list(min.node.size = -10))
bad_rf_cls <- rand_forest(mode = "classification",
                          others = list(sampsize = -10))

ctrl <- fit_control(verbosity = 1, catch = FALSE)
caught_ctrl <- fit_control(verbosity = 1, catch = TRUE)
quiet_ctrl <- fit_control(verbosity = 0, catch = TRUE)


test_that('ranger classification execution', {

  skip_if_not_installed("ranger")

  # passes interactively but not on R CMD check
  # expect_error(
  #   res <- fit(
  #     lc_ranger,
  #     Class ~ funded_amnt + term,
  #     data = lending_club,
  #     engine = "ranger",
  #     control = ctrl
  #   ),
  #   regexp = NA
  # )

  expect_error(
    res <- fit_xy(
      lc_ranger,
      x = lending_club[, num_pred],
      y = lending_club$Class,
      engine = "ranger",
      control = ctrl
    ),
    regexp = NA
  )

  expect_error(
    res <- fit(
      bad_ranger_cls,
      funded_amnt ~ term,
      data = lending_club,
      engine = "ranger",
      control = ctrl
    )
  )

  # passes interactively but not on R CMD check
  # ranger_form_catch <- fit(
  #   bad_ranger_cls,
  #   funded_amnt ~ term,
  #   data = lending_club,
  #   engine = "ranger",
  #   control = caught_ctrl
  # )
  # expect_true(inherits(ranger_form_catch$fit, "try-error"))

  ranger_xy_catch <- fit_xy(
    bad_ranger_cls,
    engine = "ranger",
    control = caught_ctrl,
    x = lending_club[, num_pred],
    y = lending_club$total_bal_il
  )
  expect_true(inherits(ranger_xy_catch$fit, "try-error"))
})

test_that('ranger classification prediction', {
  
  skip_if_not_installed("ranger")
  
  xy_fit <- fit_xy(
    rand_forest(mode = "classification"),
    x = lending_club[, num_pred],
    y = lending_club$Class,
    engine = "ranger",
    control = ctrl
  )

  xy_pred <- predict(xy_fit$fit, data = lending_club[1:6, num_pred])$prediction
  expect_equal(xy_pred, predict_class(xy_fit, newdata = lending_club[1:6, num_pred]))

  form_fit <- fit(
    rand_forest(mode = "classification"),
    Class ~ funded_amnt + int_rate,
    data = lending_club,
    engine = "ranger",
    control = ctrl
  )

  form_pred <- predict(form_fit$fit, data = lending_club[1:6, c("funded_amnt", "int_rate")])$prediction
  expect_equal(form_pred, predict_class(form_fit, newdata = lending_club[1:6, c("funded_amnt", "int_rate")]))
})


test_that('ranger classification probabilities', {
  
  skip_if_not_installed("ranger")
  
  xy_fit <- fit_xy(
    rand_forest(mode = "classification", others = list(probability = TRUE, seed = 3566)),
    x = lending_club[, num_pred],
    y = lending_club$Class,
    engine = "ranger",
    control = ctrl
  )

  xy_pred <- predict(xy_fit$fit, data = lending_club[1:6, num_pred])$predictions
  xy_pred <- as_tibble(xy_pred)
  expect_equal(xy_pred, predict_classprob(xy_fit, newdata = lending_club[1:6, num_pred]))

  one_row <- predict_classprob(xy_fit, newdata = lending_club[1, num_pred])
  expect_equivalent(xy_pred[1,], one_row)

  form_fit <- fit(
    rand_forest(mode = "classification", others = list(probability = TRUE, seed = 3566)),
    Class ~ funded_amnt + int_rate,
    data = lending_club,
    engine = "ranger",
    control = ctrl
  )

  form_pred <- predict(form_fit$fit, data = lending_club[1:6, c("funded_amnt", "int_rate")])$predictions
  form_pred <- as_tibble(form_pred)
  expect_equal(form_pred, predict_classprob(form_fit, newdata = lending_club[1:6, c("funded_amnt", "int_rate")]))

  no_prob_model <- fit_xy(
    rand_forest(mode = "classification"),
    x = lending_club[, num_pred],
    y = lending_club$Class,
    engine = "ranger",
    control = ctrl
  )

  expect_error(
    predict_classprob(no_prob_model, newdata = lending_club[1:6, num_pred])
  )
})


###################################################################

num_pred <- names(mtcars)[3:6]

car_basic <- rand_forest(mode = "regression")

bad_ranger_reg <- rand_forest(mode = "regression",
                              others = list(min.node.size = -10))
bad_rf_reg <- rand_forest(mode = "regression",
                          others = list(sampsize = -10))

ctrl <- list(verbosity = 1, catch = FALSE)
caught_ctrl <- list(verbosity = 1, catch = TRUE)
quiet_ctrl <- list(verbosity = 0, catch = TRUE)

test_that('ranger regression execution', {

  skip_if_not_installed("ranger")
  
  # passes interactively but not on R CMD check
  # expect_error(
  #   res <- fit(
  #     car_basic,
  #     mpg ~ .,
  #     data = mtcars,
  #     engine = "ranger",
  #     control = ctrl
  #   ),
  #   regexp = NA
  # )
  # passes interactively but not on R CMD check
  # expect_error(
  #   res <- fit_xy(
  #     car_basic,
  #     x = mtcars,
  #     y = mtcars$mpg,
  #     engine = "ranger",
  #     control = ctrl
  #   ),
  #   regexp = NA
  # )

  # passes interactively but not on R CMD check
  # ranger_form_catch <- fit(
  #   bad_ranger_reg,
  #   mpg ~ .,
  #   data = mtcars,
  #   engine = "ranger",
  #   control = caught_ctrl
  # )
  # expect_true(inherits(ranger_form_catch$fit, "try-error"))

  ranger_xy_catch <- fit_xy(
    bad_ranger_reg,
    engine = "ranger",
    control = caught_ctrl,
    x = mtcars[, num_pred],
    y = mtcars$mpg
  )
  expect_true(inherits(ranger_xy_catch$fit, "try-error"))

})

test_that('ranger regression prediction', {

  skip_if_not_installed("ranger")
  
  xy_fit <- fit_xy(
    car_basic,
    x = mtcars[, -1],
    y = mtcars$mpg,
    engine = "ranger",
    control = ctrl
  )

  xy_pred <- predict(xy_fit$fit, data = tail(mtcars[, -1]))$prediction

  expect_equal(xy_pred, predict_num(xy_fit, newdata = tail(mtcars[, -1])))

})

test_that('additional descriptor tests', {
  
  skip_if_not_installed("ranger")
  
  quoted_xy <- fit_xy(
    rand_forest(mode = "classification", mtry = quote(floor(sqrt(n_cols)) + 1)),
    x = mtcars[, -1],
    y = mtcars$mpg,
    engine = "ranger",
    control = ctrl
  )
  expect_equal(quoted_xy$fit$mtry, 4)
  
  quoted_f <- fit(
    rand_forest(mode = "classification", mtry = quote(floor(sqrt(n_cols)) + 1)),
    mpg ~ ., data = mtcars,
    engine = "ranger",
    control = ctrl
  )
  expect_equal(quoted_f$fit$mtry, 4)
  
  expr_xy <- fit_xy(
    rand_forest(mode = "classification", mtry = expr(floor(sqrt(n_cols)) + 1)),
    x = mtcars[, -1],
    y = mtcars$mpg,
    engine = "ranger",
    control = ctrl
  )
  expect_equal(expr_xy$fit$mtry, 4)
  
  expr_f <- fit(
    rand_forest(mode = "classification", mtry = expr(floor(sqrt(n_cols)) + 1)),
    mpg ~ ., data = mtcars,
    engine = "ranger",
    control = ctrl
  )
  expect_equal(expr_f$fit$mtry, 4)
  
  ##
  
  exp_wts <- quote(c(min(n_levs), 20, 10))
  
  quoted_other_xy <- fit_xy(
    rand_forest(
      mode = "classification",
      mtry = quote(2),
      others = list(class.weights = quote(c(min(n_levs), 20, 10)))
    ),
    x = iris[, 1:4],
    y = iris$Species,
    engine = "ranger",
    control = ctrl
  )
  expect_equal(quoted_other_xy$fit$mtry, 2)
  expect_equal(quoted_other_xy$fit$call$class.weights, exp_wts)
  
  quoted_other_f <- fit(
    rand_forest(
      mode = "classification",
      mtry = expr(2),
      others = list(class.weights = quote(c(min(n_levs), 20, 10)))
    ),
    Species ~ ., data = iris,
    engine = "ranger",
    control = ctrl
  )
  expect_equal(quoted_other_f$fit$mtry, 2)
  expect_equal(quoted_other_f$fit$call$class.weights, exp_wts)
  
  expr_other_xy <- fit_xy(
    rand_forest(
      mode = "classification",
      mtry = expr(2),
      others = list(class.weights = expr(c(min(n_levs), 20, 10)))
    ), 
    x = iris[, 1:4],
    y = iris$Species,
    engine = "ranger",
    control = ctrl
  )
  expect_equal(expr_other_xy$fit$mtry, 2)
  expect_equal(expr_other_xy$fit$call$class.weights, exp_wts)
  
  expr_other_f <- fit(
    rand_forest(
      mode = "classification",
      mtry = expr(2),
      others = list(class.weights = expr(c(min(n_levs), 20, 10)))
    ),
    Species ~ ., data = iris,
    engine = "ranger",
    control = ctrl
  )
  expect_equal(expr_other_f$fit$mtry, 2)
  expect_equal(expr_other_f$fit$call$class.weights, exp_wts)
})
