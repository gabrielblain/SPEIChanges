
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

## Basic Instructions

### Loading the packages

To use the package, first load it into your R session with:

``` r
library(SPEIChanges)
# This will also load the required dependencies
```

### Loading dataset from Campinas, state of Sao Paulo, Brazil

The package includes a sample dataset containing daily meteorological
data including precipitation, potential evapotranspiration and the
difference between them (P - PE). To load the dataset, use the following
command:

``` r
data(Campinas)
head(Campinas)
#>         Date  Tavg  Tmax  Tmin   WS    RH       Ra       Rn  Rain       PE
#> 1 01/01/1995 22.90 27.16 19.81 2.31 86.00 44.14692 13.30339  7.14 3.583251
#> 2 02/01/1995 21.61 24.99 19.23 1.74 90.45 44.12867 13.39148 19.15 3.406381
#> 3 03/01/1995 21.78 24.62 19.58 2.04 89.11 44.10818 13.65543 22.88 3.484567
#> 4 04/01/1995 22.04 25.30 19.71 1.79 90.94 44.08545 11.57560 13.39 2.995245
#> 5 05/01/1995 22.25 25.48 18.91 1.48 89.27 44.06045 14.81535  5.60 3.822785
#> 6 06/01/1995 23.41 27.66 19.84 2.32 85.87 44.03317 21.63854  1.32 5.413021
#>         PPE
#> 1  3.556749
#> 2 15.743619
#> 3 19.395433
#> 4 10.394755
#> 5  1.777215
#> 6 -4.093021
```

### Aggregating daily P - PE data at a specified time scale.

To aggregate daily P - PE data at quasi-week time scales, use the
`PPEaggreg` function. This function requires a numeric vector or matrix
of daily P - PE values, a start date, and the desired time scale (TS) in
quasi-weeks. The default TS is 4, which corresponds to a monthly scale.

``` r
daily.PPE <- Campinas[, 11]
PPE.at.TS <- PPEaggreg(daily.PPE, start.date = "1995-01-01", TS = 4)
#> Done. Just ensure the last quasi-week is complete.
#>   The last day of your series is 31 and TS is 4
head(PPE.at.TS)
#>      Year Month quasiWeek PPE.at.TS4
#> [1,] 1995     1         4   123.3181
#> [2,] 1995     2         1   242.7979
#> [3,] 1995     2         2   299.9392
#> [4,] 1995     2         3   382.2785
#> [5,] 1995     2         4   289.6011
#> [6,] 1995     3         1   122.4033
```

### Calculating SPEI changes using nonstationary models

To calculate SPEI changes using nonstationary models, use the
`SPEIChanges` function. This function requires the aggregated P - PE
data and the number of nonstationary models to fit (1 to 5 nonstationary
models). The function will return a list containing the SPEI values and
the fitted nonstationary models.

``` r
Changes_SPEI <- spsUtil::quiet(SPEIChanges(PPE.at.TS=PPE.at.TS, nonstat.models = 5))
head(Changes_SPEI$Changes.Freq.Drought)
#>      Month quasiWeek Model StatNormalPPE NonStatNormalPPE ChangeMod ChangeSev
#> [1,]     1         1     2         56.36           -18.88     30.92     20.45
#> [2,]     1         2     2         70.88             8.98     25.84     16.97
#> [3,]     1         3     2         80.55            34.31     20.04     13.38
#> [4,]     1         4     6        106.61             2.74     39.64     24.22
#> [5,]     2         1     2         74.15            29.13     16.12     10.45
#> [6,]     2         2     1         31.61            31.61      0.00      0.00
#>      ChangeExt
#> [1,]     10.40
#> [2,]      8.63
#> [3,]      7.12
#> [4,]      8.87
#> [5,]      5.41
#> [6,]      0.00
head(Changes_SPEI$data.week)
#>   Year Month quasiWeek PPE.at.TS  SPEI Exp.Acum.Prob Actual.Acum.Prob
#> 1 1995     1         4   123.318 0.202         0.580            0.586
#> 2 1995     2         1   242.798 1.683         0.954            0.906
#> 3 1995     2         2   299.939 3.000         0.999            0.999
#> 4 1995     2         3   382.278 2.737         0.997            0.991
#> 5 1995     2         4   289.601 2.438         0.993            0.983
#> 6 1995     3         1   122.403 1.211         0.887            0.744
#>   ChangeDryFreq
#> 1     NoDrought
#> 2     NoDrought
#> 3     NoDrought
#> 4     NoDrought
#> 5     NoDrought
#> 6     NoDrought
head(Changes_SPEI$GEV.parameters)
#>   Month quasiWeek  Location    Scale      Shape
#> 1     1         1 108.02215 66.82375 -0.1712404
#> 2     1         1 102.64194 66.82375 -0.1712404
#> 3     1         1  97.26174 66.82375 -0.1712404
#> 4     1         1  91.88153 66.82375 -0.1712404
#> 5     1         1  86.50132 66.82375 -0.1712404
#> 6     1         1  81.12112 66.82375 -0.1712404
```

## Auxiliary functions

The package also includes auxiliary functions such as `Ra.R`,
`ET0_HS.R`, `ET0_PM.R`, and `ET0_PT.R`. These functions may be used for
calculating daily extraterrestrial solar radiation and potential
Evapotranspiration rates, using Hargreaves-Samani, Penman and Monteith,
and Preistley-Taylor methods. respectively.

``` r
# Example of using Ra function
daily.Ra <- Ra(lat = -23, start.date = "1995-01-01", end.date = "1995-01-10")
head(daily.Ra)
#>         Date       Ra
#> 1 1995-01-01 42.74798
#> 2 1995-01-02 42.73080
#> 3 1995-01-03 42.71186
#> 4 1995-01-04 42.69113
#> 5 1995-01-05 42.66860
#> 6 1995-01-06 42.64426
```

``` r
# Example of using ET0_HS function
Tavg <- Campinas[, 2]
Tmax <- Campinas[, 3]
Tmin <- Campinas[, 4]
Ra <- Campinas[, 7]
ET0_HS_values <- ET0_HS(Ra = Ra, Tavg = Tavg, Tmax = Tmax, Tmin = Tmin)
head(ET0_HS_values) 
#>           ET0
#> [1,] 4.572989
#> [2,] 3.918323
#> [3,] 3.679357
#> [4,] 3.898363
#> [5,] 4.246155
#> [6,] 4.763736
# Example of using ET0_PM function
Rn <- Campinas[, 8]
WS <- Campinas[, 5]
RH <- Campinas[, 6]
ET0_PM_values <- ET0_PM(Tavg = Tavg,
       Tmax = Tmax,
       Tmin = Tmin,
       Rn = Rn,
       RH = RH,
       WS = WS,
       Alt = 658)
#> Warning in Soil_Heat_Flux(Tavg): The first 3 G values were set to zero
head(ET0_PM_values)
#>        ET0_PM
#> [1,] 3.583251
#> [2,] 3.406381
#> [3,] 3.484567
#> [4,] 2.995245
#> [5,] 3.822785
#> [6,] 5.413021
# Example of using ET0_PT function
ET0_PT_values <- ET0_PT(Tavg = Tavg, Rn = Rn)
#> Warning in Soil_Heat_Flux(Tavg): The first 3 G values were set to zero
head(ET0_PT_values)
#>         ET0_PT
#> [1,]  6.831958
#> [2,]  6.876447
#> [3,]  7.012089
#> [4,]  5.955282
#> [5,]  7.522152
#> [6,] 10.842309
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
