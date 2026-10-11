library(shiny)

# Helper Functions
# Returns NULL if everything's fine, otherwise returns an error.
# Checks in order: empty, NA, outside [0, 1], sum =/= 1
check_probs <- function(p, tol = 1e-8) {
  if (length(p) == 0) {
    return("You have entered nothing.")
  }
  if (any(is.na(p))) {
    return("Your probabilities contain missing or invalid numbers.")
  }
  if (any(p < 0 | p > 1)) {
    return("Your probabilities must be in [0, 1].")
  }
  if (abs(sum(p) - 1) > tol) {
    return(sprintf("Your probabilities sum to %.6f, not 1.", sum(p)))
  }
  NULL
}
  
# Checks the outcomes for empty, NA, and duplicates.
check_values <- function(x, name = "values") {
  if (length(x) == 0) {
    return(paste("No", name, "entered."))
  }
  if (anyNA(x)) {
    return(paste("Some", name, "are not valid numbers."))
  }
  if (anyDuplicated(x)) {
    return(paste("Duplicate", name, "found."))
  }
  NULL
}

# Reads an input, if missing returns NA
get_num <- function(id, input) {
  v <- input[[id]]
  
  if (is.null(v) || length(v) == 0) {
    return(NA_real_)
  } else {
    return(as.numeric(v))
  }
}

# Computers our mean and variance
dist_stats <- function(x, p) {
  mean_val <- sum(x * p)
  var_val  <- sum(x^2 * p) - (mean_val^2)
  
  list(mean = mean_val, variance = var_val)
}

# Plots the PMF
plot_pmf <- function(x, p, main) {
  plot(x, p, 
       type = "h", 
       lwd = 3, 
       ylim = c(0, max(p) * 1.1),
       xlab = "x", 
       ylab = "P(X = x)", 
       main = main)
  points(x, p, pch = 16)
}

# Plots the CDF
plot_cdf <- function(x, p, main_title) {
  sorted_indices <- order(x)
  
  sorted_x <- x[sorted_indices]
  sorted_p <- p[sorted_indices]
  
  cumulative_probs <- c(0, cumsum(sorted_p))
  
  cdf_step_function <- stepfun(sorted_x, cumulative_probs)
  
  plot(
    cdf_step_function, 
    main = main_title,
    xlab = "x", 
    ylab = "F(x)", 
    verticals = FALSE, 
    pch = 16      
  )
}

# UI 
ui <- navbarPage(
  title = "Summative Assessment 1 | Section I: Task 2 by Chance Jayden Valdez & Heinz Nicole Tan",
  
  # Task 2
  tabPanel(
    title = "Discrete Random Variable Calculator",
    tabsetPanel(
      tabPanel("Univariate (Single Variable)",
               sidebarLayout(
                 sidebarPanel(
                   numericInput("uni_n", "Number of Outcomes", value = 3, min = 2, max = 10, step = 1),
                   uiOutput("uni_inputs"),
                   hr(),
                   uiOutput("uni_validity")
                 ),
                 mainPanel(
                   h4("Distribution"),
                   tableOutput("uni_table"),
                   tableOutput("uni_stats"),
                   fluidRow(
                     column(6, plotOutput("uni_pmf")),
                     column(6, plotOutput("uni_cdf"))
                   )
                 )
               )
      ),
      tabPanel("Bivariate (Two Variables / Joint)",
               sidebarLayout(
                 sidebarPanel(
                   numericInput("bi_nx", "Number of X Outcomes", value = 2, min = 2, max = 5, step = 1),
                   numericInput("bi_ny", "Number of Y Outcomes", value = 2, min = 2, max = 5, step = 1),
                   uiOutput("bi_x_labels"),
                   uiOutput("bi_y_labels"),
                   uiOutput("bi_joint_inputs"),
                   hr(),
                   textOutput("bi_validity")
                 ),
                 mainPanel(
                   h4("Joint Distribution"),
                   tableOutput("bi_joint"),
                   hr(),
                   selectInput("bi_which", "Distribution to inspect",
                               c("Marginal of X: P(X = x)" = "mx", 
                                 "Marginal of Y: P(Y = y)" = "my",
                                 "Conditional: P(X | Y = y)" = "xgy", 
                                 "Conditional: P(Y | X = x)" = "ygx")),
                   uiOutput("bi_cond_ui"),
                   tableOutput("bi_dist"),
                   tableOutput("bi_stats"),
                   fluidRow(
                     column(6, plotOutput("bi_pmf")),
                     column(6, plotOutput("bi_cdf"))
                   )
                 )
               )
      )
    )
  )
)

server <- function(input, output, session) {
  
  # --- Univariate ---
  
  output$uni_inputs <- renderUI({
    n <- input$uni_n
    req(n, n >= 2)
    
    input_rows <- list()
    for (i in seq_len(n)) {
      input_rows[[i]] <- fluidRow(
        column(6, numericInput(paste0("uni_x", i), paste0("x", i), value = i - 1)),
        column(6, numericInput(paste0("uni_p", i), paste0("p", i), value = 1 / n,
                               min = 0, max = 1, step = 0.01))
      )
    }
    tagList(input_rows)
  })
  
  uni <- reactive({
    n <- input$uni_n
    if (is.null(n) || is.na(n) || n < 2 || n != round(n)) {
      return(list(err = "Number of outcomes must be a whole number, at least 2."))
    }
    
    x <- numeric(n)
    p <- numeric(n)
    for (i in seq_len(n)) {
      x[i] <- get_num(paste0("uni_x", i), input)
      p[i] <- get_num(paste0("uni_p", i), input)
    }
    
    err <- check_values(x)
    if (is.null(err)) {
      err <- check_probs(p)
    }
    list(x = x, p = p, err = err)
  })
  
  output$uni_validity <- renderUI({
    e <- uni()$err
    if (is.null(e)) {
      div(style = "color:green;", strong("Valid distribution."))
    } else {
      div(style = "color:red;", strong(e))
    }
  })
  
  output$uni_table <- renderTable({
    req(is.null(uni()$err))
    o <- order(uni()$x)
    data.frame(x = uni()$x[o], p = uni()$p[o], F = cumsum(uni()$p[o]))
  }, digits = 4)
  
  output$uni_stats <- renderTable({
    req(is.null(uni()$err))
    s <- dist_stats(uni()$x, uni()$p)
    data.frame(Mean = s$mean, Variance = s$variance, SD = sqrt(s$variance))
  }, digits = 4)
  
  output$uni_pmf <- renderPlot({
    req(is.null(uni()$err))
    plot_pmf(uni()$x, uni()$p, "pmf")
  })
  
  output$uni_cdf <- renderPlot({
    req(is.null(uni()$err))
    plot_cdf(uni()$x, uni()$p, "cdf")
  })
  
  # --- Bivariate ---
  
  output$bi_x_labels <- renderUI({
    req(input$bi_nx, input$bi_nx >= 2)
    
    x_boxes <- list()
    for (i in seq_len(input$bi_nx)) {
      x_boxes[[i]] <- numericInput(paste0("bi_x", i), paste0("x", i), value = i - 1)
    }
    tagList(x_boxes)
  })
  
  output$bi_y_labels <- renderUI({
    req(input$bi_ny, input$bi_ny >= 2)
    
    y_boxes <- list()
    for (j in seq_len(input$bi_ny)) {
      y_boxes[[j]] <- numericInput(paste0("bi_y", j), paste0("y", j), value = j - 1)
    }
    tagList(y_boxes)
  })
  
  output$bi_joint_inputs <- renderUI({
    nx <- input$bi_nx
    ny <- input$bi_ny
    req(nx, ny, nx >= 2, ny >= 2)
    
    joint_rows <- list()
    for (i in seq_len(nx)) {
      row_boxes <- list()
      for (j in seq_len(ny)) {
        row_boxes[[j]] <- column(
          floor(12 / ny),
          numericInput(paste0("bi_p_", i, "_", j), paste0("p(", i, ",", j, ")"),
                       value = 1 / (nx * ny), min = 0, max = 1, step = 0.01)
        )
      }
      joint_rows[[i]] <- fluidRow(row_boxes)
    }
    
    tagList(
      h5("Joint probabilities p(xi, yj)"),
      joint_rows
    )
  })
  
  bi <- reactive({
    nx <- input$bi_nx
    ny <- input$bi_ny
    
    ok <- function(n) {
      if (is.null(n) || is.na(n) || n < 2 || n != round(n)) {
        return(FALSE)
      } else {
        return(TRUE)
      }
    }
    
    if (!ok(nx) || !ok(ny)) {
      return(list(err = "Outcome counts must be whole numbers, at least 2."))
    }
    
    x <- numeric(nx)
    for (i in seq_len(nx)) {
      x[i] <- get_num(paste0("bi_x", i), input)
    }
    
    y <- numeric(ny)
    for (j in seq_len(ny)) {
      y[j] <- get_num(paste0("bi_y", j), input)
    }
    
    P <- matrix(NA_real_, nx, ny)
    for (i in seq_len(nx)) {
      for (j in seq_len(ny)) {
        P[i, j] <- get_num(paste0("bi_p_", i, "_", j), input)
      }
    }
    
    err <- check_values(x, "X values")
    if (is.null(err)) {
      err <- check_values(y, "Y values")
    }
    if (is.null(err)) {
      err <- check_probs(as.vector(P))
    }
    if (!is.null(err)) {
      return(list(err = err))
    }
    
    dimnames(P) <- list(paste0("x=", x), paste0("y=", y))
    list(x = x, y = y, P = P, px = rowSums(P), py = colSums(P), err = NULL)
  })
  
  output$bi_validity <- renderText({
    e <- bi()$err
    if (is.null(e)) {
      "Valid joint distribution."
    } else {
      e
    }
  })
  
  output$bi_joint <- renderTable({
    req(is.null(bi()$err))
    d <- bi()
    rbind(cbind(d$P, "p_X" = d$px), "p_Y" = c(d$py, sum(d$P)))
  }, rownames = TRUE, digits = 4)
  
  output$bi_cond_ui <- renderUI({
    req(is.null(bi()$err))
    d <- bi()
    
    if (input$bi_which == "xgy") {
      selectInput("bi_cv", "Condition on Y =", setNames(seq_along(d$y), d$y))
    } else if (input$bi_which == "ygx") {
      selectInput("bi_cv", "Condition on X =", setNames(seq_along(d$x), d$x))
    }
  })
  
  bi_sel <- reactive({
    req(is.null(bi()$err))
    d <- bi()
    
    switch(input$bi_which,
           mx = list(x = d$x, p = unname(d$px), lab = "Marginal of X"),
           my = list(x = d$y, p = unname(d$py), lab = "Marginal of Y"),
           xgy = {
             req(input$bi_cv)
             j <- as.integer(input$bi_cv)
             validate(need(j <= length(d$y), "Pick a Y value."),
                      need(d$py[j] > 0, "P(Y = y) is 0, so this conditional is undefined."))
             list(x = d$x, p = unname(d$P[, j] / d$py[j]), lab = paste("X | Y =", d$y[j]))
           },
           ygx = {
             req(input$bi_cv)
             i <- as.integer(input$bi_cv)
             validate(need(i <= length(d$x), "Pick an X value."),
                      need(d$px[i] > 0, "P(X = x) is 0, so this conditional is undefined."))
             list(x = d$y, p = unname(d$P[i, ] / d$px[i]), lab = paste("Y | X =", d$x[i]))
           })
  })
  
  output$bi_dist <- renderTable({
    s <- bi_sel()
    o <- order(s$x)
    data.frame(value = s$x[o], p = s$p[o], F = cumsum(s$p[o]))
  }, digits = 4)
  
  output$bi_stats <- renderTable({
    s <- bi_sel()
    st <- dist_stats(s$x, s$p)
    data.frame(Mean = st$mean, Variance = st$variance, SD = sqrt(st$variance))
  }, digits = 4)
  
  output$bi_pmf <- renderPlot({
    s <- bi_sel()
    plot_pmf(s$x, s$p, paste("pmf:", s$lab))
  })
  
  output$bi_cdf <- renderPlot({
    s <- bi_sel()
    plot_cdf(s$x, s$p, paste("cdf:", s$lab))
  })
  
}

shinyApp(ui = ui, server = server)