source(here::here("R/utils.R"))

get_links <- function(url) {
  page <- read_html(url)
  links <-
    page %>%
    html_nodes("a") %>%
    html_attr("href")
  return(links)
}


# Download Illinois data --------------------------------------------------
setwd(here::here("data/raw/illinois"))
links <- get_links("http://www.icjia.state.il.us/research/overview")
download.file("http://www.icjia.state.il.us/assets/datasets/130/xls/JailBookings.xls",
              destfile = "illinois_county_jail_admissions.xls",
              mode = "wb")
download.file("http://www.icjia.state.il.us/assets/datasets/120/xls/JailADP.xls",
              destfile = "illinois_county_jail_adp.xls",
              mode = "wb")



# Download Kentucky data --------------------------------------------------
setwd(here::here("data/raw/kentucky"))
links <- get_links("https://corrections.ky.gov/About/researchandstats/pages/weeklyjail.aspx")
links <- links[grep("weekly.*jail/[0-9]{4}", links, ignore.case = TRUE)]

for (link in links) {
  link  <- paste0("https://corrections.ky.gov", link)

  file_name <- gsub(".*weekly.*jail", "", link)
  file_name <- gsub("/|-", "_", file_name)
  file_name <- paste0("kentucky_weekly_jail", file_name)

  download.file(link,
                destfile = file_name,
                mode = "wb")
}


# Download Maryland data --------------------------------------------------
setwd(here::here("data/raw/maryland"))
download.file("http://mgaleg.maryland.gov/Pubs/BudgetFiscal/2016fy-budget-docs-capital-ZB02-Local-Jails-and-Detention-Centers.pdf",
              destfile = "maryland_county_jail.pdf",
              mode = "wb")



# Download Michigan data --------------------------------------------------
setwd(here::here("data/raw/michigan"))
links <- get_links(paste0("https://www.michigan.gov/corrections/",
                          "0,4551,7-119-33218_49414-207773--,00.html"))
links <- links[grep("JPIS.*[0-9]{4}.*.pdf", links)]

for (link in links) {

  year <- gsub(".*(CY|_)([0-9]{4}_).*", "\\2", link)
  year <- gsub("_", "", year)
  # For some reason the 2007 file is mislabeled as 2006 but says
  # 2007 inside the document!
  if (grepl("265015", link)) {
    year <- 2007
  }
  link_name = paste0("michigan_county_jails_",
                     year,
                     ".pdf")
  if (grepl("Explanation", link)) {
    link_name <- "michigan_county_jails_data_explanation.pdf"
  }
  link <- paste0("https://www.michigan.gov", link)
  download.file(link, destfile = link_name, mode = "wb")
}

# Download New York data --------------------------------------------------
setwd(here::here("data/raw/new_york"))
download.file("https://www.criminaljustice.ny.gov/crimnet/ojsa/jail_pop_y.pdf",
              destfile = "new_york_county_jail_2009_2018.pdf",
              mode = "wb")

# Download Pennsylvania data ----------------------------------------------

setwd(here::here("data/raw/pennsylvania"))
for (year in 2006:2016) {
  url <- paste0("http://pacrimestats.info/trend_reports.aspx?p=\\2006\\Prisons",
                "_and_Jails\\County_Jail_Population")

  links <- get_links(gsub("2006", year, url))
  links <- links[grep("County_Jail_Population.*pdf", links)]
  link  <- links[1]
  link  <- paste0("http://pacrimestats.info/", link)

  download.file(link,
                destfile = paste0("pennsylvania_county_jail_", year, ".pdf"),
                mode = "wb")
}

for (year in 2006:2016) {
  link <- paste0("http://pacrimestats.info/PCCDReports/CrimeJusticeTrendReports",
                 "/2006/Prisons_and_Jails/County_Jail_Population/ctyjail2006.pdf")


  link <- gsub("20[0-9]{2}", year, link)
  link_name <- paste0("pennsylvania_county_jail_",
                      year,
                      ".pdf")
  result = tryCatch({
    download.file(link, destfile = link_name, mode = "wb")
  }, error = function(e) {
    link <- paste0("http://pacrimestats.info/PCCDReports/CrimeJusticeTrend",
                   "Reports/2007/Prisons_and_Jails/County_Jail_Population/",
                   "2007_County_Jail_Population_FULL.pdf")
    link <- gsub("20[0-9]{2}", year, link)
    download.file(link, destfile = link_name, mode = "wb")
  })
}

# Download Tennessee data -------------------------------------------------
setwd(here::here("data/raw/tennessee"))
links <- get_links(paste0("https://www.tn.gov/correction/statistics-and-",
                          "information/jail-summary-reports.html"))
links <- links[grep("Jail[^Female]", links)]

for (link in links) {
  link_name = paste0("tennessee_county_jail_",
                     tolower(gsub(".*Jail(.*)[0-9]{4}.*",
                                  "\\1_", link)),
                     readr::parse_number(link),
                     ".pdf")
  link <- paste0("https://www.tn.gov", link)
  download.file(link, destfile = link_name, mode = "wb")
}

# Download Washington data ------------------------------------------------
setwd(here::here("data/raw/washington"))
links <- get_links("https://www.waspc.org/cjis-statistics---reports")
links <- links[grep("jail.*statistics|jail.*stats|jaildata",
                    links)]
for (link in links) {
  link_name = paste0("washington_county_jail_",
                     readr::parse_number(link),
                     ".xlsx")
  link <- paste0("https://www.waspc.org", link)
  download.file(link, destfile = link_name, mode = "wb")
}


# Download Georgia data ------------------------------------------------
setwd(here::here("data/raw/georgia"))


nodes <- data.frame(year = 2015:2019,
                    node = c(4036,
                             4035,
                             4030,
                             4777,
                             5617))

for (i in 1:nrow(nodes)) {
  links <- get_links(paste0("https://www.dca.ga.gov/node/", nodes$node[i]))
  links <- links[grep("jail.*report.*.pdf", links)]

  for (n in 1:length(links)) {
    link_name = paste0("georgia_county_jail_",
                       tolower(month.abb[n]),
                       "_",
                       nodes$year[i],
                       ".pdf")

    download.file(links[n], destfile = link_name, mode = "wb")
  }
}
