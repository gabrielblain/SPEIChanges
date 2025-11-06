
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SPEIChanges

<!-- badges: start -->

<!-- badges: end -->

A package designed to improve the interpretation of the Standardized
Precipitation-Evapotranspiration index (SPEI) under changing climate
conditions.

## Authors

**Gabriel Constantino Blain**  
Maintainer and main author  
[ORCID 0000-0001-8832-7734](https://orcid.org/0000-0001-8832-7734)  
Email: <gabriel.blain@sp.gov.br>

**Graciela R. Sobierajski**  
Co-author  
[ORCID 0000-0002-7211-9268](https://orcid.org/0000-0002-7211-9268)

**Leticia L. Martins**  
Co-author  
[ORCID 0000-0002-0299-3005](https://orcid.org/0000-0002-0299-3005)

## Basic Description

The {SPEIChanges} package was created to detect climate changes in the
balance between precipitation and evapotranspiration and quantify how
they affect the probability of a drought event, quantified by the SPEI
(Vicente-Serrano et al. 2010), occurring. The package applies a
nonstationary approach proposed by Blain et al. (2022) and Blain et
al. (2025), designed to isolate the effect of such changes on the
central tendency and dispersion of the SPEI frequency distributions.

The package depends on R (\>= 3.5) and imports the following packages:
{CropWaterBalance}, {lubridate}, {zoo}, {extRemes}, {spsUtil}, {stats},
and {utils}.

## Installation

You can install the development version of SPEIChanges from
[GitHub](https://github.com/gabrielblain/SPEIChanges) with:

``` r
# install.packages("pak")
pak::pak("gabrielblain/SPEIChanges")
```

## Example

This is a basic example which shows a basic use of the two most
important package’s functions:

``` r
library(SPEIChanges)
daily.PPE <- Campinas[, 11]
PPE.at.TS <- PPEaggreg(daily.PPE, start.date = "1995-01-01", TS = 4)
#> Done. Just ensure the last quasi-week is complete.
#>   The last day of your series is 31 and TS is 4
Changes_SPEI <- SPEIChanges(PPE.at.TS=PPE.at.TS, nonstat.models = 5)
#> Warning in SPEIChanges(PPE.at.TS = PPE.at.TS, nonstat.models = 5): Less than 30
#> years of P - PE records. Longer periods are highly recommended.
#> Fitting the GEV-based models to each quasi-weekly series...
#>   |                                                                              |                                                                      |   0%  |                                                                              |=                                                                     |   2%  |                                                                              |===                                                                   |   4%  |                                                                              |====                                                                  |   6%  |                                                                              |======                                                                |   8%  |                                                                              |=======                                                               |  10%  |                                                                              |=========                                                             |  12%  |                                                                              |==========                                                            |  15%  |                                                                              |============                                                          |  17%  |                                                                              |=============                                                         |  19%  |                                                                              |===============                                                       |  21%  |                                                                              |================                                                      |  23%  |                                                                              |==================                                                    |  25%  |                                                                              |===================                                                   |  27%  |                                                                              |====================                                                  |  29%  |                                                                              |======================                                                |  31%  |                                                                              |=======================                                               |  33%  |                                                                              |=========================                                             |  35%  |                                                                              |==========================                                            |  38%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  42%  |                                                                              |===============================                                       |  44%  |                                                                              |================================                                      |  46%  |                                                                              |==================================                                    |  48%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  52%  |                                                                              |======================================                                |  54%  |                                                                              |=======================================                               |  56%  |                                                                              |=========================================                             |  58%  |                                                                              |==========================================                            |  60%  |                                                                              |============================================                          |  62%  |                                                                              |=============================================                         |  65%  |                                                                              |===============================================                       |  67%  |                                                                              |================================================                      |  69%  |                                                                              |==================================================                    |  71%  |                                                                              |===================================================                   |  73%  |                                                                              |====================================================                  |  75%  |                                                                              |======================================================                |  77%  |                                                                              |=======================================================               |  79%  |                                                                              |=========================================================             |  81%  |                                                                              |==========================================================            |  83%  |                                                                              |============================================================          |  85%  |                                                                              |=============================================================         |  88%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  92%  |                                                                              |==================================================================    |  94%  |                                                                              |===================================================================   |  96%  |                                                                              |===================================================================== |  98%  |                                                                              |======================================================================| 100%
```

## References

Blain G C, Sobierajski G R, Weight E, Martins L L, Sparks, A. H. 2025.
The SPIChanges R-package: Improving the interpretation of the
standardized precipitation index under changing climate conditions,
Environmental Modelling & Software, 192, DOI:
10.1016/j.envsoft.2025.106573.

Blain G C, Sobierajski G R, Weight E, Martins L L, Xavier A C F 2022.
Improving the interpretation of standardized precipitation index
estimates to capture drought characteristics in changing climate
conditions. International Journal of Climatology, 42, 5586-5608. DOI:
10.1002/joc.7550

Vicente-Serrano, S. M., S. Beguería, and J. I. López-Moreno, 2010: A
Multiscalar Drought Index Sensitive to Global Warming: The Standardized
Precipitation Evapotranspiration Index. J. Climate, 23, 1696–1718, DOI:
10.1175/2009JCLI2909.1.

Package `CropWaterBalance` Blain et al. DOI:
10.32614/CRAN.package.CropWaterBalance

Package `lubridate` Spinu et al. DOI: 10.32614/CRAN.package.lubridate

Package `zoo` Zeileis and Grothendieck DOI: 10.32614/CRAN.package.zoo

Package `extRemes` Gilleland and Katz DOI:
10.32614/CRAN.package.extRemes

Package `spsUtil` Sproles et al. DOI: 10.32614/CRAN.package.spsUtil

Package `stats` R Core Team DOI: 10.32614/CRAN.package.stats

Package `utils` R Core Team DOI: 10.32614/CRAN.package.utils
