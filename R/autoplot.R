#' Autoplot EBLUP results
#'
#' @param model EBLUP model
#' @param variable variable to plot
#' @param ... further arguments passed to or from other methods.
#'
#' @examples
#' library(saens)
#' library(ggplot2)
#'
#' m1 <- eblupfh(y ~ x1 + x2 + x3, data = mys, vardir = "var", cluster = "clust")
#' autoplot(m1)
#'
#' @importFrom rlang .data
#' @importFrom ggplot2 ggplot aes geom_line scale_color_manual theme labs element_text autoplot
#'
#' @export
autoplot.eblupres <- function(model, variable = 'RSE', ...){
  fit <- model$fit
  model <- model$df_res
  y <- model$y

  variable <- match.arg(toupper(variable), c('RSE', 'RRMSE', 'MSE', 'EBLUP'))
  if (variable %in% c('RSE', 'RRMSE')) {
    ytitle <- 'RRMSE'
    df_res <- data.frame(
      area = 1:length(y),
      rse = sqrt(model$vardir) * 100 / y,
      rse_eblup = sqrt(model$mse) * 100 / model$eblup
    )
  }else if (variable == 'MSE') {
    ytitle <- 'MSE'
    df_res <- data.frame(
      area = 1:length(y),
      mse = model$vardir,
      mse_eblup = model$mse
    )
  }else if (variable == 'EBLUP') {
    ytitle <- all.vars(fit$model_formula)[1]
    df_res <- data.frame(
      area = 1:length(y),
      direct = y,
      eblup_est = model$eblup
    )
  }
  df_res <- tidyr::pivot_longer(df_res, -.data$area)

  ggplot(df_res, aes(x = .data$area, y = .data$value, group = .data$name, col = .data$name)) +
    geom_line(lwd = 0.7) +
    labs(
      x = 'Area',
      y = ytitle,
      title = NULL,
      subtitle = NULL
    ) +
    scale_color_manual(
      NULL,
      values = c('tomato', 'royalblue1'),
      labels = c('Direct estimation', 'EBLUP')
    ) +
    theme(
      plot.title = element_text(face = 2, vjust = 0),
      plot.subtitle = element_text(colour = 'gray30', vjust = 0)
    )
}
