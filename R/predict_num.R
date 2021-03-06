#' @rdname predict.model_fit
#' @inheritParams predict.model_fit
#' @method predict_num model_fit
#' @export predict_num.model_fit
#' @export
# TODO add ...
predict_num.model_fit <- function (object, newdata, ...) {
  if (object$spec$mode != "regression")
    stop("`predict_num` is for predicting numeric outcomes.  ",
         "Use `predict_class` or `predict_prob` for ",
         "classification models.", call. = FALSE)
  
  if (!any(names(object$spec$method) == "pred"))
    stop("No prediction module defined for this model.", call. = FALSE)
  
  newdata <- prepare_data(object, newdata)
  
  # preprocess data
  if (!is.null(object$spec$method$pred$pre))
    newdata <- object$spec$method$pred$pre(newdata, object)
  
  # create prediction call
  pred_call <- make_pred_call(object$spec$method$pred)
  
  res <- eval_tidy(pred_call)
  # post-process the predictions
  
  if (!is.null(object$spec$method$pred$post)) {
    res <- object$spec$method$pred$post(res, object)
  }
  
  if (is.vector(res)) {
    res <- unname(res)
  } else
    res <- as.data.frame(res)
  res
}


#' @export
#' @rdname predict.model_fit
#' @inheritParams predict_num.model_fit
predict_num <- function (object, ...)
  UseMethod("predict_num")
