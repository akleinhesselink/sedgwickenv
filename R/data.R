#' Geolocation and environmental characteristics of 24 study sites at the UCSB Sedgwick Reserve.
#'
#' A dataset describing the position, soil characteristics, light interception,
#' and surface temperature at 24 vegetation study sites at the UCSB Sedgwick Reserve.
#' Sites originally established by Nathan Kraft and Gaurav Kandlikar in 2016.
#' Soil characteristics are based on standard soil analysis conducted by A&L. Western
#' Agricultural labs on samples collected from common gardens at each site by
#' Gaurav Kandlikar. Soil depth and light interception data were collected by
#' Andrew Kleinhesselink.
#'
#' @format A data frame with 24 rows and 30 variables:
#' \describe{
#'   \item{site}{Site code based on original site number used by G.K. and N.K.}
#'   \item{name}{site nickname}
#'   \item{lon}{decimal longitude}
#'   \item{lat}{decimal latitude}
#'   \item{ele}{elevation (m), determined from USGS DEM}
#'   \item{type}{sites either upper or lower, upper sites on serpentine soil}
#'   \item{microsite}{for upper sites, sites on hummocks are identified}
#'   \item{Tmax}{Average daily Tmax \ifelse{html}{\out{&#176;}}{\&deg;}C temperature for March. Recorded directly with iButton placed in PVC housing on soil surface at each site}
#'   \item{Tmin}{Average daily Tmax \ifelse{html}{\out{&#176;}}{\&deg;}C temperature for March. Recorded directly with iButton placed in PVC housing on soil surface at each site}
#'   \item{soil_organic}{soil organic matter (\%)}
#'   \item{pH}{soil pH}
#'   \item{CEC}{soil cation exchange capacity (meq per 100g)}
#'   \item{NH4_N}{soil ammonium concentration (ppm)}
#'   \item{Nitrate}{soil Nitrate (ppm)}
#'   \item{sand}{Soil sand content (\%)}
#'   \item{clay}{Soil clay content (\%)}
#'   \item{Ca}{soil Calcium (ppm)}
#'   \item{Mg}{soil Magnesium (ppm)}
#'   \item{K}{soil Potassium (ppm)}
#'   \item{light_above}{Ambient light (mmol per m\ifelse{html}{\out{<sup>3</sup>}}{\eqn{^3}} measured at 1.5 m above site at two locations at midday}
#'   \item{light_below}{Ambient light (mmol per m\ifelse{html}{\out{<sup>3</sup>}}{\eqn{^3}} measured at soil surface, below any vegetion at the site}
#'   \item{light_use}{vegetation light interception.  Calculated as (light_above - light_below)/light_above}
#'   \item{soil_depth}{Average soil depth (cm). Determined by driving metal rod into two locations in five plots at each site, n = 10}
#'   \item{soil_depth_sd}{Standard deviation (cm) of soil depth measurements at each site. n = 10 per site}
#'   \item{Apr_2016_GWC}{Soil water content from soils collected April 2016 (g/g)}
#'   \item{Apr_2017_GWC}{Soil water content from soils collected April 2017 (g/g)}
#'   \item{Jan_2018_GWC}{Soil water content from soils collected January 2018 (g/g)}
#'   \item{May_2016_GWC}{Soil water content from soils collected May 2016 (g/g)}
#'   \item{avg_soil_moisture}{Average of April and May soil moisture measurements}
#' }
"sedgwick_env"


#' Sedgwick reserve boundary.
#'
#' Spatial boundary of Sedgwick Reserve for making maps. WGS84 geographical projection.
#'
#' @format A SpatialPolygons object.
#' \describe{
#' }
"sedgwick_boundary"

#' Sedgwick Elevation Layer
#'
#' Digital Elevation Model for Sedgwick Reserve downloaded from USGS.
#' 1/3 Arc-second Resolution (~10m). Geographical projection on GRS80 ellipsoid.
#'
#' @format A RasterLayer object with 12 slots
#' \describe{
#' }
"sedgwick_DEM"

#' Sedgwick Surface Temperature Data
#'
#' Spring surface temperatures for each of 24 study sites.  Temperatures recorded with
#' iButton temperature loggers housed in short section of white PVC pipe placed on soil
#' surface at each site. Temperatures were logged every 4 hours and maximum and minimum
#' daily temperatures were calculated. Temperatures were recorded from February to June
#' 2016 and then again in 2018.
#'
#' @format A dataframe with 6636 rows and 7 variables
#' \describe{
#'   \item{site}{Site code based on original site number used by G.K. and N.K.}
#'   \item{date}{Date of sample in "Y-m-d" format}
#'   \item{doy}{Day of year}
#'   \item{Tmin}{Minimum temperature \ifelse{html}{\out{&#176;}}{\&deg;}C recorded during that day}
#'   \item{Tmax}{Maximum temperature \ifelse{html}{\out{&#176;}}{\&deg;}C recorded during that day}
#'   \item{Tavg}{Average temperature \ifelse{html}{\out{&#176;}}{\&deg;}C.  Tavg \= Tmin + Tamx/2 }
#'   \item{daily_range}{Range between maximum and minimum temperature \ifelse{html}{\out{&#176;}}{\&deg;}C during day}
#' }
"sedgwick_ibutton"

#' Soil depth at each of the 24 sites.
#'
#' Soil depth recorded at two locations within five plots (n=10) at each of the 24 site.
#' Soil depth was measured by driving a thin metal rod into the soil and recorded the
#' depth at which rock was hit and the rod stopped penetrating. Depth measured in the
#' spring of 2017 by A. Kleinhesselink.
#'
#' @format A dataframe with 240 rows and 4 variables
#' \describe{
#'   \item{site}{Site code based on original site number used by G.K. and N.K.}
#'   \item{plot}{Plot number at each site (1-5)}
#'   \item{rep}{Two sampling locations located at opposite corners of each plot}
#'   \item{depth_cm}{maximum depth (cm)}
#' }
"sedgwick_soil_depth"

#' Spring moisture at each of the 24 sites.
#'
#' Soil moisture was determined gravimetrically in the spring of 2016, 2017 and 2018
#' at each of the 24 sites. Shallow (<10 cm) soil was collected from multiple locations
#' at each site.  These were homogenized and then weighed to get a wet weight.  They were
#' then dried at 60 \ifelse{html}{\out{&#176;}}{\&deg;}C for 72 hours and then re-weighed
#' to get dry weight.  Soil moisture by mass was recorded as (wet-dry)/dry weight.
#'
#' @format A dataframe with 96 rows and 3 variables
#' \describe{
#'   \item{site}{Site code based on original site number used by G.K. and N.K.}
#'   \item{date}{Date of sample in "Y-m-d" format}
#'   \item{GWC}{Soil moisture expressed as fraction of dry weight}
#' }
"sedgwick_soil_moisture"

