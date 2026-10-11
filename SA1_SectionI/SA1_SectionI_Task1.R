# Summative Assessment 1 | Section I: Task 1
# Authors: Heinz Nicole Tan & Chance Jayden Valdez

# Instructions for Execution:
# 1. Clear the console before running by pressing 'Esc' then 'Ctrl + L'.
# 2. Locate the 'Source' button at the top right of the script editor panel.
# 3. Click 'Source' exactly once to run the entire script.
# 4. When prompted in the console to `enter x1 (0.10 to 0.40)`, click inside 
#    the console pane, type your numerical value, and press 'Enter'.
# 5. Repeat this input process for the remaining 5 prompts.

suppressWarnings(rm(x1, x2, x3, y1, y2, y3, valid, probability))

valid <- FALSE

cat("Conditions for the inputs:\n")
cat("1. Each x must be between 0.10 and 0.40, and x1 + x2 + x3 = 1.\n")
cat("2. Each y must be between 0.01 and 0.05, and y1 + y2 + y3 = 0.12.\n\n")

again <- TRUE

while (again) {
  
  valid <- FALSE
  
  while (!valid) {
    x1 <- as.numeric(readline("Enter x1 (0.10 to 0.40): "))
    x2 <- as.numeric(readline("Enter x2 (0.10 to 0.40): "))
    x3 <- as.numeric(readline("Enter x3 (0.10 to 0.40): "))
    
    y1 <- as.numeric(readline("Enter y1 (0.01 to 0.05): "))
    y2 <- as.numeric(readline("Enter y2 (0.01 to 0.05): "))
    y3 <- as.numeric(readline("Enter y3 (0.01 to 0.05): "))
    
    if (!anyNA(c(x1, x2, x3, y1, y2, y3)) &&
        ((x1 >= 0.10 && x1 <= 0.40) &&
         (x2 >= 0.10 && x2 <= 0.40) &&
         (x3 >= 0.10 && x3 <= 0.40) &&
         abs(x1 + x2 + x3 - 1) < 1e-9) &&
        ((y1 >= 0.01 && y1 <= 0.05) &&
         (y2 >= 0.01 && y2 <= 0.05) &&
         (y3 >= 0.01 && y3 <= 0.05) &&
         abs(y1 + y2 + y3 - 0.12) < 1e-9)) {
      
      valid <- TRUE
      probability <- (x1 * y1) + (x2 * y2) + (x3 * y3)
      cat("The probability that a randomly selected product is defective is", round(probability, 4), "\n")
      
    } else {
      cat("Input does not meet the given conditions. Please try again.\n")
    }
  }
  
  answer <- tolower(trimws(readline("Calculate again? (y/n): ")))
  if (answer != "y") {
    again <- FALSE
  }
}

cat("Done.\n")