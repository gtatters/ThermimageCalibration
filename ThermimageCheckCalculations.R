# Check Thermimage calculations against FLIR Researcher Max output
# The purpose of this script is to compare the raw2temp() conversion calculations in the 
# Thermimage package against the standard values generated from numerous FLIR software programs

# Define all libraries and functions
library("fields")
library("Thermimage")
thermal.palette<-palette.choose("ironbow")  # can choose form "flir","ironbow"...need to add others

# Import Thermal Image Data
setwd("~/Dropbox/R/MyPackages/ThermimageCalibration")
r1<-as.matrix(read.csv("IguanaRawR&D.csv", header=FALSE))
r2<-as.matrix(read.csv("IguanaRawExaminIR.csv", header=FALSE))
mean(r1-r2)
# if mean = 0 then both software outputs are using the same algorithm
# Some FLIR programs allow you to export the raw binary data (FLIR R&D Software, ExaminIR)
# This requires that you obtain the camera calibration constants, embedded in the file
# structure.  
# See Exiftool (http://search.cpan.org/dist/Image-ExifTool/lib/Image/ExifTool/FLIR.pm)

# here is the image directly as imported (notice the scale should be in raw units
# where max = 2^16=65535 corresponding to the data storage method from FLIR jpgs)
par(mar=c(5.1,5.1,5.1,5.1))
image.plot(r1, useRaster=T, bty="n", col=thermal.palette, xlab="", ylab="", xaxt="n", yaxt="n",
           asp=480/640, legend.width=0.5)

# FLIR is constantly creating new software and often with very little difference in practical
# functionality to the user, but at great expense to a research budget.  Does it matter which
# software to use in terms of temperature estimates?

# load in 3 files that represent the same image set to realistic emissivity and environmental
# values but the data were exported from each program (Thermacam Researcher Pro v2.9, ExaminIR,
# and Flir Research R&D Max):
trealThermcam<-as.matrix(read.csv("IguanaActualTemperatureE0.96Temps20Thermcam.csv", header=FALSE))
trealExamIR<-as.matrix(read.csv("IguanaActualTemperatureE0.96Temps20ExaminIR.csv", header=FALSE))
trealRD<-as.matrix(read.csv("IguanaActualTemperatureE0.96Temps20R&D.csv", header=FALSE, sep=";"))

mean(trealThermcam-trealExamIR) # -0.0786 oC difference
mean(trealThermcam-trealRD)     # -0.1396 oC difference
mean(trealExamIR-trealRD)       # -0.0609 oC difference
# 3 programs by FLIR that open the same image and camera settings set to the 
# same values and they lead to estimated temperatures that differ by 0.07 to 0.13 oC!
# no reason is provided for this.  This is the challenge of working with proprietary software
# but these differences are fairly small, although it does suggest caution

# Here, the same image was analysed in Thermacam Researcher Pro but the settings changed 
# on purpose and the temperature data exported to csv files
tt0.9<-as.matrix(read.csv("Iguana_T0.9.csv", header=FALSE)) # transmission window = 0.9
tt0.7<-as.matrix(read.csv("Iguana_T0.7.csv", header=FALSE)) # transmission window = 0.7
trt40<-as.matrix(read.csv("Iguana_RT40.csv", header=FALSE)) # transmission window = 1, but the window temperature was set to 40C 
te0.9<-as.matrix(read.csv("Iguana_E0.9.csv", header=FALSE)) # Emissivity = 0.9

# clearly, changing parameters will distort estimates of temperature, but this is to be expected:
mean(tt0.9-trealThermcam)  # 1.549 oC
mean(tt0.7-trealThermcam)  # 5.527 oC
mean(trt40-trealThermcam)  # -0.95 oC
mean(te0.9-trealThermcam)  # 0.88 oC

flirsettings("IguanaImage.jpg", camvals="-*Planck*")$Info

# Create 5 calculated values using Thermimage raw2temp() function:
trealc<-raw2temp(r1, E=0.96, OD=1, RTemp=20, ATemp=20, IRT=1, RH=50,PR1 = 21106.77, PB = 1501, PF = 1, PO = -7340, PR2 = 0.012545258)
tt0.9c<-raw2temp(r1, E=0.96, OD=1, RTemp=20, ATemp=20, IRT=0.9, RH=50, PR1 = 21106.77, PB = 1501, PF = 1, PO = -7340, PR2 = 0.012545258)
tt0.7c<-raw2temp(r1, E=0.96, OD=1, RTemp=20, ATemp=20, IRT=0.7, RH=50, PR1 = 21106.77, PB = 1501, PF = 1, PO = -7340, PR2 = 0.012545258)
trt40c<-raw2temp(r1, E=0.96, OD=1, RTemp=40, ATemp=40, IRWTemp=40, IRT=1, RH=50, PR1 = 21106.77, PB = 1501, PF = 1, PO = -7340, PR2 = 0.012545258)
te0.9c<-raw2temp(r1, E=0.9, OD=1, RTemp=20, ATemp=20, IRT=1, RH=50,PR1 = 21106.77, PB = 1501, PF = 1, PO = -7340, PR2 = 0.012545258)


# Compare Thermimage calculated set to the same settings as exported from Thermacam Researcher Pro:
x<-trealc-trealThermcam
hist(x)
mean(x) # 0.033oC 

x<-tt0.9c-tt0.9
hist(x)
mean(x) # -0.0497 oC

x<-tt0.7c-tt0.7
hist(x)
mean(x) # 0.044 oC

x<-trt40c-trt40
hist(x)
mean(x) # -0.028 oC

x<-te0.9c-te0.9
hist(x)
mean(x) # 0.035 oC
 
# for all the above, the difference between Thermimage calculated values and Thermacam Researcher Pro
# exported values is ~0.04 oC which happens to be the resolution of the thermal camera used

# It appears that calculations are working as intended, since the algorithms were derived from
# similar source


# Finally a plot of the image used to make these comparisons: 
image.plot(rotate270.matrix(tt0.9), useRaster=TRUE, bty="n", col=thermal.palette, main="Thermacam Researcher Pro",
           xlab="", ylab="", xaxt="n", yaxt="n",  asp=480/640)

image.plot(rotate270.matrix(tt0.9c), useRaster=TRUE, bty="n", col=thermal.palette, main="Thermimage Calculated",
           xlab="", ylab="", xaxt="n", yaxt="n",  asp=480/640)

image.plot(rotate270.matrix(tt0.9c-tt0.9), useRaster=TRUE, bty="n", col=thermal.palette, main="Thermimage Calculated",
           xlab="", ylab="", xaxt="n", yaxt="n",  asp=480/640)
 
plotTherm(tt0.9, h=640, w=480, minrangeset=20, maxrangeset=46, trans="rotate270.matrix")
plotTherm(tt0.9c, h=640, w=480, minrangeset=20, maxrangeset=46, trans="rotate270.matrix")
plotTherm(tt0.9-tt0.9c, h=640, w=480, minrangeset=-0.08, maxrangeset=0.08, trans="rotate270.matrix")
