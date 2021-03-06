## data import from URL
gdURL <- "http://www.stat.ubc.ca/~jenny/notOcto/STAT545A/examples/gapminder/data/gapminderDataFiveYear.txt"
gDat <- read.delim(file = gdURL)
str(gDat)
(snippet <- subset(gDat, country == "Canada"))
install.packages("plyr", dependencies = TRUE)
library(plyr)
(maxLeByCont <- ddply(gDat, ~ continent, summarize, maxLifeExp = max(lifeExp)))
str(maxLeByCont)
levels(maxLeByCont$continent)
(minGDPByCont <- ddply(gDat, ~ continent, summarize, minGdpPercap = min(gdpPercap)))
ddply(gDat, ~continent, summarize, nUniqCountries = length(unique(country)))
ddply(gDat, ~ continent, function(x) return(c(nUniqCountries = length(unique(x$country)))))
ddply(gDat, ~ continent, summarize,
      minLifeExp = min(lifeExp), maxLifeExp = max(lifeExp),
      medGdpPercap = median(gdpPercap))
jCountry <- "France"  # pick, but do not hard wire, an example
(jDat <- subset(gDat, country == jCountry))  # temporary measure!
install.packages("lattice")
library(lattice)
xyplot(lifeExp ~ year, jDat, type = c("p", "r"))  # always plot the data
jFit <- lm(lifeExp ~ year, jDat)
summary(jFit)
(yearMin <- min(gDat$year))
jFit <- lm(lifeExp ~ I(year - yearMin), jDat)
summary(jFit)
class(jFit)
mode(jFit)
## str(jFit) # too ugly to print here but you should look
names(jFit)
jFit$coefficients
coef(jFit)
jFun <- function(x) coef(lm(lifeExp ~ I(year - yearMin), x))
jFun(jDat)  # trying out our new function ... yes still get same numbers
jFun <- function(x) {
  estCoefs <- coef(lm(lifeExp ~ I(year - yearMin), x))
  names(estCoefs) <- c("intercept", "slope")
  return(estCoefs)
}
jFun(jDat)  # trying out our improved function ... yes still get same numbers
jFun(subset(gDat, country == "Canada"))
jFun(subset(gDat, country == "Uruguay"))
jFun(subset(gDat, country == "India"))
jCoefs <- ddply(gDat, ~country, jFun)
str(jCoefs)
tail(jCoefs)
install.packages("xtable", dependencies = TRUE)
library(xtable)
set.seed(916)
foo <- jCoefs[sample(nrow(jCoefs), size = 15), ]
foo <- xtable(foo)
print(foo, type = "html", include.rownames = FALSE)
View(foo)
jCoefs <- ddply(gDat, ~country, jFun)
jCoefs <- ddply(gDat, ~country + continent, jFun)
str(jCoefs)
tail(jCoefs)
set.seed(916)
foo <- jCoefs[sample(nrow(jCoefs), size = 15), ]
foo <- arrange(foo, intercept)
## foo <- foo[order(foo$intercept), ] # an uglier non-plyr way
foo <- xtable(foo)
print(foo, type = "html", include.rownames = FALSE)
View(foo)
(yearMin <- min(gDat$year))
jFun <- function(x) {
  estCoefs <- coef(lm(lifeExp ~ I(year - yearMin), x))
  names(estCoefs) <- c("intercept", "slope")
  return(estCoefs)
}
jCoefs <- ddply(gDat, ~country, jFun)
head(jCoefs)
jFunTwoArgs <- function(x, cvShift = 0) {
  estCoefs <- coef(lm(lifeExp ~ I(year - cvShift), x))
  names(estCoefs) <- c("intercept", "slope")
  return(estCoefs)
}
jCoefsSilly <- ddply(gDat, ~country, jFunTwoArgs)
head(jCoefsSilly)
jCoefsSane <- ddply(gDat, ~country, jFunTwoArgs, cvShift = 1952)
head(jCoefsSane)
jCoefsBest <- ddply(gDat, ~country, jFunTwoArgs, cvShift = min(gDat$year))
head(jCoefsBest)
