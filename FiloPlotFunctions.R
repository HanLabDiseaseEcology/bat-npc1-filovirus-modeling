#'This function creates a couple of variable importance plots
#' @param imp_data These are the variable importance data created from the bootstrapping process. You should preprocess these data to have one row per variable with the columns being: var (variable name), min (minimum linerange value, either 95% confidence interval or minimum value), max (maximum linerange value, either 95% confidence interval or maximum value), mean (mean value), log_transform (was the variable log transformed), and type (relates to color used)
#' @param shapley_data These are the Shapley values produced from the bootstrapping process. They do not need to be processed, but should have columns for: variable (variable name), value (Shapley value), rfvalue (training data value), stdfvalue (standardized training data value from 0 to 1), mean_value (mean Shapley value), iteration (bootstrap iteration), row_index (row of training data associated with this value)
#' @param variables Vector of the variables to be plotted (if log transformed, they need to have "log_" added to the front)
#' @param color_palette A data.frame of colors to be used in this plot matched with the variable grouping. The columns for this data frame need to be labeled: value (palette values), name (variable group name that matches with the variable dictionary you are using)
#' @return This function will return a plot object showing the variable importance across the number of bootstrapped iterations
#' (left) with a companion plot showing the directionality of this importance (right)
#' @example variable.importance.plot(imp_data = SIMP, shapley_data = SHAP, variables = CHC, color_palette = COLS)
var.importance.plot <- function(imp_data, shapley_data, variables, color_palette) {
  IMP <- imp_data %>%
    ggplot() +
    geom_point(aes(x = mean,
                   y = var,
                   color = type),
               size = 2, show.legend = T) +
    geom_linerange(aes(xmin = min,
                       xmax = max,
                       y = var,
                       color = type),
                   linewidth = 1, show.legend = T) +
    scale_color_manual(name = "Variable Type",
                       limits = color_palette$name,
                       values = color_palette$value) +
    labs(x = "|SHAP value|", y = "Variable") +
    scale_y_discrete(limits = imp_data$var[order(imp_data$mean, decreasing = F)],
                     labels = imp_data$var[order(imp_data$mean, decreasing = F)]) +
    theme(panel.background = element_rect(fill = "white",
                                          color = "grey50"),
          panel.grid.major = element_line(color = "grey90"),
          legend.position = "inside",
          legend.position.inside = c(0.81, 0.28),
          legend.text = element_text(size = 6),
          legend.title = element_text(size = 8),
          legend.background = element_rect(color = "grey50",
                                           linewidth = 0.3),
          legend.key = element_rect(fill = "white"),
          axis.text.y = ggtext::element_markdown())
  DIR <- shapley_data %>%
    filter(variable %in% variables,
           !is.na(stdfvalue)) %>%
    ggplot() +
    ggbeeswarm::geom_quasirandom(aes(x = value,
                                     y = variable,
                                     color = stdfvalue)) +
    geom_vline(aes(xintercept = 0),
               linewidth = 1) +
    scale_color_viridis_c(option = "D",
                          breaks = seq(0, 1, 0.2)) +
    labs(x = "SHAP value",
         y = NULL,
         color = "Standardized\nValue") +
    scale_y_discrete(limits = variables[order(imp_data$mean, decreasing = F)]) +
    theme(panel.background = element_rect(fill = "white",
                                          color = "grey50"),
          panel.grid.major = element_line(color = "grey90"),
          aspect.ratio = 1.3,
          legend.position = "right",
          legend.key = element_rect(fill = "white"),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank()) +
    guides(color = guide_colorbar(barheight = 10,
                                  ticks = T,
                                  ticks.colour = "black",
                                  frame.colour = "black",
                                  frame.linewidth = 0.5,
                                  ticks.linewidth = 0.5))
  IMP + DIR
}
#'This function creates a horizon plot to investigate variable importance
#' @param shapley_data These are the Shapley values produced from the bootstrapping process. They do not need to be processed, but it should be a data.frame with columns for: variable (variable name), value (Shapley value), rfvalue (training data value), stdfvalue (standardized training data value from 0 to 1), mean_value (mean Shapley value), iteration (bootstrap iteration), row_index (row of training data associated with this value)
#' @param variables Vector of the variables to be plotted (if log transformed, they need to have "log_" added to the front)
#' @param var_range A vector of length two that shows the minimum and maximum Shapley value found within these data. Used to determine the color gradient scale
#' @return A horizon plot object that shows the strength and directionality of variable importance for the chosen variables
#' @example horizon.plot(SHAP, CHC, RANGE)
horizon.plot <- function(shapley_data, variables, var_range) {
  shapley_data %>%
    filter(variable %in% variables,
           !is.na(stdfvalue)) %>%
    mutate(std_cat = cut(stdfvalue, 100, labels = seq(0.01, 1, 0.01))) %>%
    group_by(variable, std_cat) %>%
    summarise(value = mean(value, na.rm = T)) %>%
    mutate(variable = factor(variable, levels = variables)) %>%
    ggplot() +
    ggHoriPlot::geom_horizon(aes(x = std_cat, 
                     y = value,
                     fill = after_stat(Cutpoints)),
                 origin = 0,
                 horizonscale = seq(var_range[1], var_range[2], 3)) +
    scale_fill_hcl(palette = 'RdBu', reverse = F) +
    facet_grid(variable~.) +
    scale_y_continuous(expand = c(0, 0)) +
    scale_x_discrete(breaks = as.character(seq(0, 1, 0.1)),
                     expand = c(0, 0)) +
    theme(axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          strip.text.y = element_text(angle = 0),
          strip.background = element_rect(fill = "seashell",
                                          color = "black"),
          panel.background = element_rect(fill = "grey70",
                                          color = "black"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.spacing.y = unit(0, "lines"),
          panel.border = element_rect(fill = "transparent",
                                      color = "black"))
}
#'This function creates a set of 16 partial dependence plots
#' @param variables Vector of the variables to be plotted (if log transformed, they need to have "log_" added to the front). They should be of length 16.
#' @param shapley_data These are the Shapley values produced from the bootstrapping process. They do not need to be processed, but it should be a data.frame with columns for: variable (variable name), value (Shapley value), rfvalue (training data value), stdfvalue (standardized training data value from 0 to 1), mean_value (mean Shapley value), iteration (bootstrap iteration), row_index (row of training data associated with this value)
#' @param train_data The data.frame used to train these models (used to grab the distribution of values for each variable). The column names should match what is seen in the variables vector as that is what is used to grab the values.
#' @param colors_vec A vector of color values that should be equal in length to the number of variables given (16)
#' @return Returns a partial dependence plot object that is actually 33 panels (16 panels of partial dependence plots, 16 panels of the density curves showing the distribution of values in the training data, panel of enlarged y-axis title from {cowplot})
#' @example partial.dependence.plot(CHC, SHAP, DATA, p_cols)
partial.dependence.plot <- function(variables, shapley_data, train_data, colors_vec) {
  MNVL <- shapley_data %>%
    filter(!is.na(rfvalue)) %>%
    group_by(variable, ID, rfvalue) %>%
    summarise(value = mean(value, na.rm = T),
              rfvalue = mean(rfvalue, na.rm = T)) %>%
    filter(variable %in% variables) %>%
    ungroup() %>%
    data.frame()
  PDPR <- shapley_data %>%
    filter(variable %in% variables)
  PDPR %>%
    filter(variable %in% variables) %>%
    group_by(variable) %>%
    summarise(min = min(value),
              max = max(value))
  PDP <- lapply(1:16, function(i) {
    PDPR %>%
      filter(variable == variables[i]) %>%
      ggplot(aes(x = rfvalue,
                 y = value,
                 group = iteration)) +
      stat_smooth(geom = "line",
                  se = F,
                  alpha = 0.5,
                  color = "grey70") +
      geom_smooth(data = MNVL %>% filter(variable == variables[i]),
                  inherit.aes = F,
                  method = "loess",
                  aes(x = rfvalue,
                      y = value),
                  color = colors_vec[i],
                  se = F,
                  linewidth = 1.5) +
      labs(y = NULL,
           x = variables[i]) +
      theme(aspect.ratio = 1,
            panel.background = element_rect(fill = "white",
                                            color = "grey50"),
            panel.grid.major = element_line(color = "grey90"),
            panel.border = element_rect(fill = "transparent",
                                        color = "black"),
            axis.text.x = element_blank(),
            axis.ticks.x = element_blank(),
            axis.title.x = element_blank(),
            axis.ticks.length.x = unit(0, "pt"),
            plot.margin = margin(0, 0, 0, 0, "pt"))
  })
  p_lab <- cowplot::ggdraw() +
    cowplot::draw_label("Shapley Score",
                        angle = 90,
                        #fontface = "bold",
                        size = 14) 
  RUGV <- train_data[, variables] %>%
    reshape2::melt() %>%
    rename(rfvalue = value) %>%
    mutate(value = 0)
  TPLT <- foreach(i = 1:length(variables)) %do% {
    RUGV %>%
      filter(variable == variables[i]) %>%
      ggplot() +
      geom_density(aes(x = rfvalue),
                   fill = colors_vec[i],
                   alpha = 0.4,
                   color = colors_vec[i]) +
      scale_x_continuous(position = "bottom") +
      scale_y_reverse(expand = expansion(mult = c(0.1, 0))) +
      labs(x = variables[i],
           y = NULL) +
      theme(panel.background = element_rect(fill = "white",
                                            color = "grey50"),
            panel.grid.major = element_line(color = "grey80"),
            panel.grid.minor = element_line(color = "transparent"),
            panel.border = element_rect(fill = "transparent",
                                        color = "black"),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank(),
            panel.grid.major.y = element_line(color = "transparent"),
            aspect.ratio = 0.2,
            plot.margin = margin(0,0,0,0,"pt"))
  }
  PTPL <- lapply(1:16, function(i) PDP[[i]]/TPLT[[i]])
  cowplot::plot_grid(p_lab,
                     patchwork::wrap_plots(PTPL, ncol = 4),
                     nrow = 1,
                     rel_widths = c(0.05, 1),
                     rel_heights = c(1, 1)) +
    theme(plot.background = element_rect(fill = "white",
                                         color = "transparent"))
}
#'This function creates a horizon plot to investigate variable importance
#' @param train_data These are the Shapley values produced from the bootstrapping process. They do not need to be processed, but it should be a data.frame with columns for: variable (variable name), value (Shapley value), rfvalue (training data value), stdfvalue (standardized training data value from 0 to 1), mean_value (mean Shapley value), iteration (bootstrap iteration), row_index (row of training data associated with this value)
#' @param variables Vector of the variables to be plotted (if log transformed, they need to have "log_" added to the front)
#' @param label A vector of length two that shows the minimum and maximum Shapley value found within these data. Used to determine the color gradient scale
#' @param proportion
#' @param breaks
#' @param recipe
#' @param workflow_data
#' @param pars_data
#' @param model_objective
#' @param pred_data description description description description description description description
#' @return A horizon plot object that shows the strength and directionality of variable importance for the chosen variables
#' @example horizon.plot(SHAP, CHC, RANGE)
model.predictions <- function(train.data, object.data, workflow_data, pars_data, model_objective = c("reg:squarederror"), pred.data, iterations) {
  xgb_fit <- lapply(1:iterations, function(i) {
    workflow_data %>%
      finalize_workflow(pars_data) %>%
      last_fit(object.data[[i]][[1]]) %>%
      extract_fit_parsnip()
  })
  DF <- as.data.frame(train.data)
  MOD <- xgboost(data = as.matrix(DF[, -1]),
                 label = DF[, 1],
                 params = list(objective = model_objective,
                               eta = pars_data$learn_rate,
                               max_depth = pars_data$tree_depth,
                               subsample = pars_data$sample_size,
                               colsample_bytree = pars_data$mtry,
                               min_child_weight = pars_data$min_n,
                               gamma = pars_data$loss_reduction),
                 nrounds = pars_data$trees,
                 verbose = F)
  PRED <- predict(MOD, as.matrix(pred.data[, VARS]), type = "response")
  PRED <- cbind.data.frame(species = pred.data$binomial,
                           family = pred.data$family,
                           pred = PRED)
  PRES <- foreach(i = 1:iterations, .combine = "rbind") %do% {
    shap.prep(xgb_model = extract_fit_engine(xgb_fit[[i]]),
              X_train = bake(object.data[[i]][[3]],
                             has_role("predictor"),
                             new_data = pred.data,
                             composition = "matrix")) %>%
      mutate(species = pred.data$tree_match[.$ID])
  }
  list(PRED, PRES)
}
#'This function creates a horizon plot to investigate variable importance
#' @param shapley_data These are the Shapley values produced from the bootstrapping process. They do not need to be processed, but it should be a data.frame with columns for: variable (variable name), value (Shapley value), rfvalue (training data value), stdfvalue (standardized training data value from 0 to 1), mean_value (mean Shapley value), iteration (bootstrap iteration), row_index (row of training data associated with this value)
#' @param variables Vector of the variables to be plotted (if log transformed, they need to have "log_" added to the front)
#' @param var_range A vector of length two that shows the minimum and maximum Shapley value found within these data. Used to determine the color gradient scale
#' @return A horizon plot object that shows the strength and directionality of variable importance for the chosen variables
#' @example phylo.pdp.plots(PRED[[2]], unique(balt$tree_match), TREE, )
phylo.pdp.plots <- function(shapley_preds, species_vec = unique(balt$tree_match), tree, variables) {
  PRES <- shapley_preds %>%
    filter(species %in% species_vec) %>%
    group_by(species, variable) %>%
    summarise(value = mean(value, na.rm = T)) 
  PVAL <- lapply(variables, function(i) {
    data.frame(PRES[PRES$variable == i, "value"], row.names = PRES[PRES$variable == i, ]$species)
  })
  RANGE <- c(floor(min(sapply(PVAL, min))), ceiling(max(sapply(PVAL, max))))
  foreach(i = 1:length(PVAL)) %do% {
    PTRE <- ggtree(tree,
                   size = 0.05,
                   layout = "circular",
                   aes(angle = angle))
    gheatmap(PTRE, PVAL[[i]], offset= 0, width=0.06, colnames = F, color = NA) +
      scale_fill_gradient2(low = "red3", high = "blue2",
                           limits = RANGE,
                           breaks = round(seq(RANGE[1], RANGE[2], length.out = 12), 1)) +
      labs(fill = "SHAP value",
           title = variables[i]) +
      theme_void() +
      theme(plot.margin = margin(0,0,0,0,"null"),
            panel.spacing = margin(0, 0, 0, 0, "null"),
            axis.text = element_blank(),
            plot.title = element_text(hjust = 0.5),
            axis.title = element_blank()) +
      guides(fill = guide_colorbar(barheight = 14,
                                   ticks = T,
                                   ticks.colour = "black",
                                   frame.colour = "black",
                                   frame.linewidth = 0.5,
                                   ticks.linewidth = 0.5))
  }
}


