# code to identify repeated measurements (trees and plots) using FIA data
# with fusiform rust from 2013 to 2019 in Southern US

setwd("C:/Karuns_documents/pine_disease/fusiform_hotspots")

rm(list=ls())

do.call(file.remove, 
        list(list.files("C:/Karuns_documents/pine_disease/fusiform_hotspots/temp_climate_data", 
                        full.names = TRUE)))

library(dplyr)
library(reshape)
library(ggplot2)

library(dplyr)
library(reshape)
library(ggplot2)
library(USAboundaries)
library(sf)
library(gridExtra)
library(rgdal)
library(sp)
library(raster)



# 
# # # read RCS file with tree data 
# raw_data<-readRDS("../data/FIA_all_fusiform_form_2013_2020.RDS")
# 
# source("codes/fusiform_data_to_plot_summary_fn.R")
# 
# fusiform_data_to_plot_summary_fn(raw_data)

# install.packages("USAboundariesData", repos = "https://ropensci.r-universe.dev", type = "source")

# install.packages('spDataLarge', repos='https://nowosad.github.io/drat/', type='source')


st_list = c("Alabama", "Arkansas", "Connecticut", "Delaware", "Florida",
            "Georgia", "Illinois", "Indiana",
            "Iowa", "Kansas", "Kentucky", "Louisiana",
            "Maine", "Maryland","Massachusetts",  "Michigan",
            "Minnesota", "Mississippi", "Missouri","Nebraska", 
            "New Hampshire","New Jersey",
            "New York", "North Carolina", "North Dakota",
            "Ohio", "Oklahoma", "Pennsylvania",
            "Rhode Island", "South Carolina", "South Dakota", "Tennessee",
            "Texas", "Vermont","Virginia",
            "West Virginia", "Wisconsin")
# 
# 
# devtools::install_github("ropensci/USAboundaries")
# devtools::install_github("ropensci/USAboundariesData")


states_contemporary <- us_states(states=st_list)
plot(st_geometry(states_contemporary))
title("Eastern US")

ext1<-extent(states_contemporary)
proj1<-crs(states_contemporary)


proj3<-"+proj=laea +lat_0=0 +lon_0=-80"

map <- st_transform(states_contemporary, proj3)
plot(st_geometry(map))

proj4<-crs(map)

# type_list<-c("loblolly","slash","longleaf")


type_list<-c("loblolly","slash","longleaf")
orig_list<-c(0,1)
pixelsize=30000

# vars<-c("pr","vpd")
vars<-c("pr","vpd","tasmax","tasmin","PotEvap","huss")


date1<-c(2030,2050)
date2<-c(2039,2059)

date3<-data.frame(date1,date2)

for (kk in 1:2){
start_yr<-date3[kk,1]
end_yr<-date3[kk,2]
scenario<-c(4.5)

# source("codes/extract_raw_climate_data_fn.R")
# #
# extract_raw_climate_data_fn(vars,start_yr,end_yr,scenario)


for (type in type_list){
 range_n<- paste0("range_data/range_",type,"_litt.shp")
  # lob_range <- st_read(paste0("range_data/range_",type,"_litt.shp"))
 range_n2<- st_read(range_n)
  
  # proj3<-"+proj=laea +lat_0=0 +lon_0=-80"
  
  range_map <- st_transform(range_n2, proj3)

  
  for (origincd in orig_list){

    
    datain_type<-paste0("data/",type,"_all_plots_summary.csv")
    
    disease_data=read.csv(datain_type)  
    
    source("codes/climate_netcdf_to_tiff_fn.R")
    
    climate_netcdf_to_tiff_fn(vars)
    
    
    source("codes/future_climate_netcdf_to_tiff_fn.R")
    
    
    future_climate_netcdf_to_tiff_fn(vars,start_yr,end_yr,scenario)    

source("codes/plot_predicted_hotspot_fn.R")


plot_predicted_hotspot_fn(type,disease_data,map,range_map,pixelsize,origincd)


if (origincd==0) {orgcd="natural"}

if (origincd==1) {orgcd="plant"}


filein<-paste0(type,orgcd)

datain2<-read.csv(paste0("output/hot",filein,"_climate.csv"))

prdatain2<-read.csv(paste0("output/whole_fishnet",filein,"_climate.csv"))

source("codes/machine_learning_stacked_fn.R")

gbm_minnode=8 # default is 10 use smaller values for small data size

machine_learning_stacked_fn(datain2,prdatain2,gbm_minnode)



source("codes/future_prediction_stacked_fn.R")

# type="slash"
# origincd=0

future_prediction_stacked_fn(map,range_map,type,orgcd,start_yr,end_yr,pixelsize,scenario)

do.call(file.remove, 
list(list.files("C:/Karuns_documents/pine_disease/fusiform_hotspots/temp_climate_data", 
                full.names = TRUE))) 
}
  }
}

