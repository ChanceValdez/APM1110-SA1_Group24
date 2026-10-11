# README

**Authors:** Valdez, Chance Jayden and Tan, Heinz Nicole

This README has two sections. Section I covers Tasks 1 to 3 and is opened in RStudio. Section II covers the Bitcoin and Ethereum returns analysis and is made/run as a Quarto (.qmd) file in the Positron IDE.

**Positron:** https://positron.posit.co/

---

# Section I: Task 1

## Description

This R script calculates the probability that a randomly selected product is defective, using the law of total probability across three sources:

$$
P(\text{defective}) = x_1 y_1 + x_2 y_2 + x_3 y_3
$$

where:

- $x_1, x_2, x_3$ are the proportions of products coming from each source
- $y_1, y_2, y_3$ are the defect rates of each source

## Input Conditions

The script validates all inputs and re-prompts if any condition fails.

1. $x$ values: each must satisfy $0.10 \le x_i \le 0.40$, and $x_1 + x_2 + x_3 = 1$
2. $y$ values: each must satisfy $0.01 \le y_i \le 0.05$, and $y_1 + y_2 + y_3 = 0.12$

Non numeric input is also rejected.

## Requirements

- R (any recent version)
- RStudio (recommended, since the instructions refer to its Source button)

## How to Run

1. Open the script in RStudio.
2. Clear the console: press `Esc`, then `Ctrl + L`.
3. Click the **Source** button at the top right of the script editor panel. Click it exactly once to run the whole script.
4. When the console prompts `Enter x1 (0.10 to 0.40):`, click inside the console pane, type a number, and press `Enter`.
5. Repeat for the remaining 5 prompts (x2, x3, y1, y2, y3).

## Example

Input:

```
x1 = 0.30   x2 = 0.30   x3 = 0.40
y1 = 0.04   y2 = 0.04   y3 = 0.04
```

Output:

```
The probability that a randomly selected product is defective is 0.04
```

Check by hand:

$$
0.30(0.04) + 0.30(0.04) + 0.40(0.04) = 0.012 + 0.012 + 0.016 = 0.04
$$

## After Each Calculation

The script asks `Calculate again? (y/n):`

- Type `y` to run another calculation.
- Type anything else to exit. The script prints `Done.`

## Notes

- Do not click Source more than once, or prompts may overlap.
- If the inputs are invalid, the script prints "Input does not meet the given conditions. Please try again." and restarts from x1.

---

# Section I: Task 2

## Discrete Random Variable Calculator

### What is this?

A Shiny app that works with discrete random variables (variables with separate outcomes). You enter the outcomes and their probabilities, and the app calculates and plots everything.

- **Univariate:** one variable.
- **Bivariate:** two variables together (joint distribution).

The app has one page titled **Probability Dashboard**. Tasks 1 and 3 are not part of this app.

### How to run

1. Install R and RStudio.
2. Run `install.packages("shiny")` once in the console.
3. Open the script in RStudio and click **Run App** (top right of the editor). The app opens in a new window.
4. To stop it, close the window and click the red stop sign in the console.

### How to navigate

The page has one tab, **Discrete Random Variable Calculator**, with two subtabs: **Univariate** and **Bivariate**. Inputs are on the left and results are on the right.

#### Univariate

1. Set **Number of Outcomes** (2 to 10).
2. Fill in each value $x$ and its probability $p$.
3. Check the message: green means valid, red means error (it tells you what is wrong).
4. Read the results: table ($x$, $p$, running total $F$), Mean, Variance, SD, and the pmf and cdf graphs.

#### Bivariate

1. Set **Number of X Outcomes** and **Number of Y Outcomes** (2 to 5 each).
2. Enter the X values, the Y values, and the joint probabilities $p(i,j)$. For example, $p(2,1)$ is the 2nd X together with the 1st Y.
3. The joint table shows row totals ($p_X$) and column totals ($p_Y$).
4. Use **Distribution to inspect** to pick: Marginal of X, Marginal of Y, X given Y, or Y given X. For a conditional, pick the known value in the extra dropdown.
5. Each selection shows its own table, Mean, Variance, SD, and pmf and cdf graphs.

### Rules the app checks

- No empty or non numeric boxes
- No duplicate outcome values
- Each probability is in $[0, 1]$
- All probabilities sum to 1, within a tolerance of $10^{-8}$ (not exactly 1)
- A conditional is blocked with a message if the value you condition on has probability 0

### Formulas

$$
\mu = E[X] = \sum x \, p(x)
$$

$$
\sigma^2 = \sum x^2 \, p(x) - \mu^2
$$

$$
\sigma = \sqrt{\sigma^2}
$$

Marginals are row sums and column sums of the joint table:

$$
p_X(x_i) = \sum_j p(x_i, y_j), \qquad p_Y(y_j) = \sum_i p(x_i, y_j)
$$

Conditionals divide the joint probability by the marginal of the known value:

$$
p(x_i \mid y_j) = \frac{p(x_i, y_j)}{p_Y(y_j)}, \qquad p(y_j \mid x_i) = \frac{p(x_i, y_j)}{p_X(x_i)}
$$

### Main assignments

- `check_probs`, `check_values`, `get_num`, `dist_stats`, `plot_pmf`, `plot_cdf`: saved functions (mini tools) for validating, calculating and plotting.
- `ui`: how the page looks. `server`: what the app does.
- `output$name <- render...`: a display slot on the page that refreshes automatically when inputs change.
- `uni`, `bi`: values that update themselves and gather the inputs and run the checks. `bi_sel` stores the distribution chosen in the dropdown.
- `x`, `p`, `y`, `P`: the outcomes and probabilities (`P` is the joint grid).
- `err`: the error message, or nothing if all is well.
- `d`, `s`, `o`: temporary storage for results, the selected distribution, and the sort order.

### Notes

- Defaults are equal probabilities ($1/n$ for univariate, $1/(n_x n_y)$ for bivariate), so the app starts out valid.
- Editing one probability box breaks the sum until the others are fixed.

---

# Section I: Task 3

## Searching Websites for a Key Phrase

You check websites one by one for a key phrase. Each site has the same chance $p$ of containing it, and you stop at the first success. $X$ is the number of sites checked. This follows a **Geometric distribution**.

The file simulates the search 10,000 times and checks that the results match the theory:

$$
E[X] = \frac{1}{p}, \qquad \operatorname{Var}(X) = \frac{1-p}{p^2}
$$

### How to run

1. Install R and RStudio.
2. Run `install.packages("rmarkdown")` once in the console.
3. Open the `.Rmd` file and click **Knit**. A report with text and graphs will open (PDF output needs LaTeX).

To test other chances, change `p <- 0.6` in the Setup box (any number strictly between 0 and 1) and knit again.

### What each part shows

| Part | Meaning |
|---|---|
| Setup | Sets the seed (so results are repeatable) and defines the search simulator |
| Part 1 | Blue bars are the simulated results and red dots are the theory. The simulated and theoretical mean and variance are compared |
| Part 2 | Keeps only runs where the first 3 sites failed ($X > 3$) and looks at the extra searches needed |
| Part 3 | Memoryless property: $P(X=4 \mid X>3) \approx P(X=1)$ and $P(X=5 \mid X>3) \approx P(X=2)$ |

### Main `<-` assignments

- `p`, `n`: the settings (chance and number of runs).
- `search_until_found`, `simulate_searches`: saved functions (mini tools).
- `count`, `found`, `site`: working values inside one search.
- `X`: all 10,000 simulated results.
- `pdf_sim`, `pdf_cond`: proportion tables for the graphs.
- `Xc`, `Yc`: the filtered runs ($X > 3$) and the extra searches after the first 3.
- `pa_cond`, `pa_unc`, `pb_cond`, `pb_unc`: probabilities for Part 3.

---

# Section II: Bitcoin and Ethereum Returns Analysis

## What is this?

This project analyzes how Bitcoin and Ethereum prices change over very short time periods. The changes are measured as **log returns** of the close price:

$$
r_t = \ln\left(\frac{C_t}{C_{t-1}}\right)
$$

- **Part 1:** Which probability distribution best describes Bitcoin's (BTC/USD) 1 minute returns, from Jan 1, 2012 to Sept 15, 2026?
- **Part 2:** Are Ethereum's (ETH/USD) 5 minute returns normally distributed, from Aug 7, 2015 to Sept 15, 2026? This is checked with the Shapiro Wilk test.

## Project layout

```
scripts/     resample_btc_data.py, resample_data.py
analysis/    analysis.qmd
data/raw/        (not in the repository)
data/processed/  (not in the repository)
```

`data/raw` and `data/processed` are not in the repository because the files are large. The scripts rebuild the processed files.

## What you need

1. **Python 3** and **Quarto**
2. These Python packages. Run this once in a terminal:

```
pip install pandas numpy scipy matplotlib jupyter
```

3. For the PDF, LaTeX through Quarto: `quarto install tinytex`
4. Quarto 1.4 or newer, since the report uses inline code.
5. The raw data files from Kaggle (links below).

## Data sources

- Bitcoin 1 minute data: https://www.kaggle.com/datasets/mczielinski/bitcoin-historical-data
- Kraken XETH/USD trades (2015 to 2018): https://www.kaggle.com/datasets/pvertenten/kraken-xethusd-trades
- Ethereum 1 minute data (2017 to present): https://www.kaggle.com/datasets/viniciusqroz/ethereum-historical-data

## How to run

1. Put the raw files in `data/raw` with these exact names:
   - `btcusd_1-min_data.csv`
   - `XETHZUSD.csv`
   - `ethusd_1min_ohlc.csv`
2. Run the two cleaning scripts first. They work from any folder and save their output in `data/processed`:

```
python scripts/resample_btc_data.py
python scripts/resample_data.py
```

   - `resample_btc_data.py` creates `btc_1min_returns_2012_2026.csv`
   - `resample_data.py` creates `eth_5min_returns_2015_2026.csv`
3. Render the report. It is a Quarto file, not a notebook:

```
quarto render analysis/analysis.qmd
```

   This makes a PDF and a Markdown (gfm) file.

## What the analysis does

### Part 1: Finding the best distribution (BTC)

1. Fits five candidates: **Normal, Cauchy, Laplace, Logistic and Student t**.
2. Scores each with **AIC** and **BIC**. Lower is better, and both penalize extra complexity. Student t has $k = 3$ parameters and the others have $k = 2$.
3. Uses a random sample of 100,000 returns, since fitting the full series is too slow.
4. Double checks the winner by:
   - repeating the fit on repeated random samples (`TODO`: confirm the number of samples)
   - removing exact zero returns and re fitting (`TODO`: add the result)

### Part 2: Normality test (ETH)

1. Sets up the hypotheses at a 5% significance level:
   - $H_0$: the returns are normally distributed
   - $H_1$: the returns are not normally distributed
2. Runs the **Shapiro Wilk test** on a random sample of 5,000 returns. This is the most the test can reliably handle.
3. Repeats the test on 1,000 different samples so one lucky draw does not drive the result.
4. Draws a histogram and a QQ plot, and lists the 10 largest absolute returns.

## Main results

### Part 1 (BTC, sample of 100,000 returns, seed 51)

Student t has the lowest AIC ($-187{,}468.46$) and BIC ($-187{,}439.92$). The gaps below are $\Delta\text{AIC}$ behind the best model:

| Distribution | $k$ | $\Delta\text{AIC}$ |
|---|---|---|
| Student t | 3 | 0 (best) |
| Cauchy | 2 | 754.64 |
| Laplace | 2 | 16,834.36 |
| Logistic | 2 | 45,154.54 |
| Normal | 2 | 111,091.83 |

In this table Cauchy is second and Normal is last. That ordering is only confirmed for this seed and sample size.

`TODO`: add the repeated sample wins count and the no zeros re fit result. Only say Student t still wins if it does in those runs.

### Part 2 (ETH)

Shapiro Wilk gives $W = 0.5788$ and $p = 1.75 \times 10^{-76}$. Since $p < 0.05$, we **reject normality**.

`TODO`: state the share of the 1,000 repeated samples that reject, but only after checking that the minimum and maximum $W$ differ slightly. If they are identical, the loop is testing one sample.

**Why?** Crypto returns are mostly tiny, with occasional huge jumps. A normal curve cannot capture that sharp peak and those extreme tails.

## Key assumptions

- Timestamps are Unix seconds read as UTC.
- Returns are log returns of the close price.
- Bars with zero volume are removed, and missing bars are left as gaps rather than filled.
- A return only counts if the two bars are exactly one interval apart (1 minute for BTC, 5 minutes for ETH).
- BTC returns are multiplied by 100 (shown in percent) because SciPy's optimizer fits very small values poorly.
- ETH returns stay as decimals, since the Shapiro Wilk test does not depend on scale.
- ETH uses Kraken trades before 16:45 UTC on Aug 16, 2017 and the 1 minute data after it. The one return that crosses the cutover is dropped.
- The Kraken file runs from Aug 7, 2015 to Jul 4, 2018.
- ETH has 999,488 valid returns out of 1,168,536 five minute slots.
- Data is used only up to the end of Sept 15, 2026.
- The random seed is **51**, so results are reproducible.

## Notes

- With 5,000 observations, Shapiro Wilk can reject for small departures, so rejection alone is not surprising. The very large departure is shown by the full ETH series, which has skewness of $-69.9$ and excess kurtosis of $32{,}753$. A normal distribution has both equal to 0.
- The most extreme ETH returns come from two places. Eight of the ten largest absolute returns fall between 22:35 and 23:35 UTC on May 7, 2017, a flash crash on Kraken during a DDoS attack (not a price spike). The other two are from August 2015, the first days of the Kraken file, when trades were very sparse.
