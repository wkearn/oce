% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/argo.R
\name{read.argo}
\alias{read.argo}
\title{Read an Argo Data File}
\usage{
read.argo(file, debug = getOption("oceDebug"), processingLog, ...)
}
\arguments{
\item{file}{a character string giving the name of the file to load.}

\item{debug}{a flag that turns on debugging.  Set to 1 to get a moderate amount
of debugging information, or to 2 to get more.}

\item{processingLog}{if provided, the action item to be stored in the log.
(Typically only provided for internal calls; the default that it provides is
better for normal calls by a user.)}

\item{...}{additional arguments, passed to called routines.}
}
\value{
An object of \code{\link{argo-class}}.
}
\description{
\code{read.argo} is used to read an Argo file, producing an object of type
\code{argo}. The file must be in the ARGO-style netCDF format described at
in the Argo documentation [2,3].
}
\details{
Metadata items such as \code{time}, \code{longitude} and \code{latitude}
are inferred from the data file in a straightforward way, using
\code{\link[ncdf4]{ncvar_get}} and data-variable names as listed in
the Argo documentation [2,3]. The items listed in section 2.2.3
of [3] is read from the file and stored in the \code{metadata} slot, 
with the exception of \code{longitude} and \code{latitude},
which are stored in the \code{data} slot.

String data that contain trailing blanks in the argo NetCDF
are trimmed using \code{\link{trimString}}.  One-dimensional
matrices are converted to vectors using \code{\link{as.vector}}.
Items listed in section 2.2.3 of [3] are meant to be present
in all files, but tests showed that this is not the case, and so
\code{read.argo} sets such items to \code{NULL} before saving
them in returned object.

Items are translated from upper-case Argo names to \code{oce} names
as follows.
\itemize{
\item \code{PLATFORM_NUMBER} becomes \code{id}
\item \code{PROJECT_NAME} becomes \code{projectName}
\item \code{PI_NAME} becomes \code{PIName}
\item \code{STATION_PARAMETERS} becomes \code{stationParameters}
\item \code{CYCLE_NUMBER} becomes \code{cycleNumber}
\item \code{DIRECTION} becomes \code{direction} (either \code{A} for ascending or \code{D} for descending)
\item \code{DATA_CENTRE} becomes \code{dataCentre} (note the spelling)
\item \code{DC_REFERENCE} becomes \code{DCReference}
\item \code{DATA_STATE_INDICATOR} becomes \code{dataStateIndicator}
\item \code{DATA_MODE} becomes \code{dataMode}
\item \code{INST_REFERENCE} becomes \code{instReference}
\item \code{FIRMWARE_VERSION} becomes \code{firmwareVersion}
\item \code{WMO_INST_TYPE} becomes \code{WMOInstType}
\item \code{JULD} becomes \code{juld} (and used to compute \code{time})
\item \code{JULD_QC} becomes \code{juldQc}
\item \code{JULD_QC_LOCATION} becomes \code{juldQcLocation}
\item \code{LATITUDE} becomes \code{latitude}
\item \code{LONGITUDE} becomes \code{longitude}
\item \code{POSITION_QC} becomes \code{positionQC}
\item \code{POSITIONING_SYSTEM} becomes \code{positioningSystem}
\item \code{PROFILE_QC} becomes \code{} ... FIX ME
}

It is assumed that the profile data are as listed in the NetCDF variable
called \code{STATION_PARAMETERS}. Each item can have variants, as
described in Sections 2.3.4 of [3].
For example, if \code{"PRES"} is found in \code{STATION_PARAMETERS},
then \code{PRES} (pressure) data are sought in the file, along with
\code{PRES_QC}, \code{PRES_ADJUSTED}, \code{PRES_ADJUSTED_QC}, and
\code{PRES_ERROR}. The same pattern works for other profile data. The variables
are stored with different names within the resultant \code{\link{argo-class}}
object, to match with \code{oce} conventions. Thus, \code{PRES} gets renamed
\code{pressure}, while \code{PRES_ADJUSTED} gets renamed \code{pressureAdjusted},
and \code{PRES_ERROR} gets renamed \code{pressureError}; all of these are 
stored in the \code{data} slot. Meanwhile, the quality-control flags
\code{PRES_QC} and \code{PRES_ADJUSTED_QC} are stored as \code{pressure}
and \code{pressureAdjusted} in the \code{metadata$flags} slot.
}
\section{Data sources}{

Argo data are made available at several websites. A bit of detective
work can be required to track down the data.  

Some servers provide  data for floats that surfaced in a given ocean
on a given day, the anonymous FTP server 
\url{ftp://usgodae.org/pub/outgoing/argo/geo/} being an example.

Other servers provide data on a per-float basis. A complicating
factor is that these data tend to be categorized by "dac" (data
archiving centre), which makes it difficult to find a particular
float. For example, 
\url{http://www.usgodae.org/ftp/outgoing/argo/} is the top level of
a such a repository. If the ID of a float is known but not the
"dac", then a first step is to download the text file
\url{http://www.usgodae.org/ftp/outgoing/argo/ar_index_global_meta.txt}
and search for the ID. The first few lines of that file are header,
and after that the format is simple, with columns separated by slash
(\code{/}). The dac is in the first such column and the float ID in the
second. A simple search will reveal the dac.
For example \code{data(argo)} is based on float 6900388, and the line
containing that token is
\url{bodc/6900388/6900388_meta.nc,846,BO,20120225005617}, from
which the dac is seen to be the British Oceanographic Data Centre
(\code{bodc}). Armed with that information, visit
\url{http://www.usgodae.org/ftp/outgoing/argo/dac/bodc/6900388}
and see a directory called `profiles` that contains a NetCDF
file for each profile the float made. These can be read with
\code{read.argo}. It is also possible, and probably more common,
to read a NetCDF file containing all the profiles together and for
that purpose the file
\url{http://www.usgodae.org/ftp/outgoing/argo/dac/bodc/6900388/6900388_prof.nc}
should be downloaded and provided as the \code{file} argument to
\code{read.argo}.  This can be automated as in Example 2,
although readers are cautioned that URL structures tend to change
over time.

Similar steps can be followed on other servers.
}
\examples{
\dontrun{
## Example 1: read from a local file
library(oce)
d <- read.argo("/data/OAR/6900388_prof.nc")
summary(d)
plot(d)

## Example 2: construct URL for download (brittle)
id <- "6900388"
url <- "http://www.usgodae.org/ftp/outgoing/argo"
if (!length(list.files(pattern="argo_index.txt")))
    download.file(paste(url, "ar_index_global_meta.txt", sep="/"), "argo_index.txt")
index <- readLines("argo_index.txt")
line <- grep(id, index)
if (0 == length(line)) stop("id ", id, " not found")
if (1 < length(line)) stop("id ", id, " found multiple times")
dac <- strsplit(index[line], "/")[[1]][1]
profile <- paste(id, "_prof.nc", sep="")
float <- paste(url, "dac", dac, id, profile, sep="/")
download.file(float, profile)
argo <- read.argo(profile)
summary(argo)
}


}
\author{
Dan Kelley
}
\references{
1. \url{http://www.argo.ucsd.edu/}

2. \samp{http://archimer.ifremer.fr/doc/00187/29825/40575.pdf}
(link last checked 2016-06-18)
documents the codes used in the netCDF files.

3. \samp{http://www.argodatamgt.org/content/download/4729/34634/file/argo-dm-user-manual-version-2.3.pdf}
(link last checked 2016-06-18)
is the main document describing argo data.
}
\seealso{
The documentation for \code{\link{argo-class}} explains the structure of argo
objects, and also outlines the other functions dealing with them.

Other things related to \code{argo} data: \code{\link{[[,argo-method}},
  \code{\link{[[<-,argo-method}}, \code{\link{argo-class}},
  \code{\link{argoGrid}}, \code{\link{argo}},
  \code{\link{as.argo}},
  \code{\link{handleFlags,argo-method}},
  \code{\link{plot,argo-method}},
  \code{\link{subset,argo-method}},
  \code{\link{summary,argo-method}}
}

