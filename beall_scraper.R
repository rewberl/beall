# Filename: beall_scraper.R
# Date: 2017-01-20
# Author: Richard E.W. Berl
# Email: rewberl@gmail.com
# Purpose: Scrape archived pages from Beall's List of Predatory Open Access
#           Publishers and output clean CSV files
# Packages used: rvest
# Licence: CC-BY-SA

# Load packages
library(rvest)
library(selectr)
library(stringr)

# Read pages from disk
publishers = read_html("./raw/publishers/index.html")
journals = read_html("./raw/journals/index.html")
hijacked = read_html("./raw/hijacked/index.html")
metrics = read_html("./raw/metrics/index.html")


# Scrape information from publishers page
## Uses CSS selectors obtained using SelectorGadget:
##  http://selectorgadget.com/
p = html_nodes(publishers, ".body div div div+ ul li")

## Scrape text and initial cleaning
p.text = html_text(p)
p.text = substr(p.text, 3, length(p.text))

## Scrape links to list (since some text entries have two links) and clean
p.links = list()
for (i in 1:length(p)) {
    temp1 = html_attr(html_nodes(p[i], "a"), "href")
    temp2 = substr(temp1, 74, nchar(temp1))
    if (length(temp2) == 0L) {
        p.links[[i]] = NA
    } else {
        p.links[[i]] = temp2
    }
}

### Add non-hyperlinked sites from inside text entries
p.links[[266]] = append(p.links[[266]], "http://shankargargh.org/")

### Split links to two variables
p.links.1 = rep(NA, length(p.links))
p.links.2 = rep(NA, length(p.links))
for (i in 1:length(p.links)) {
    if (!is.na(p.links[[i]][1])) {
        p.links.1[i] = p.links[[i]][1]
        if (length(p.links[[i]]) == 2) {
            p.links.2[i] = p.links[[i]][2]
        }
    }
}

## Extract alternate names from text and remove from text
for (i in 1:length(p.text)) {
    temp = c()
    if (str_detect(p.text[i], "\\(")) {
        temp = append(temp,
                      str_extract(p.text[i], "(?<=\\().*?(?=\\))"))
    }
    if (str_detect(p.text[i], "\\/")) {
        temp = append(temp,
                      str_extract(p.text[i], "([^/]+$)"))
    }
    if (str_detect(p.text[i], fixed("see", ignore_case=T))) {
        temp = append(temp,
                      tail(unlist(str_split(p.text[i],
                                            fixed("see",
                                                  ignore_case=T))), 1))
    }
    if (str_detect(p.text[i], fixed("also called", ignore_case=T))) {
        temp = append(temp,
                      tail(unlist(str_split(p.text[i],
                                            fixed("also called",
                                                  ignore_case=T))), 1))
    }
    if (str_detect(p.text[i], fixed("re-branded as", ignore_case=T))) {
        temp = append(temp,
                      tail(unlist(str_split(p.text[i],
                                            fixed("re-branded as",
                                                  ignore_case=T))), 1))
    }
    # From alternate names: split by ";", "|", ",", ":", remove junk characters, split by white space
    # From text: remove all content matched above, then characters used for matching
}


### Anything in parentheses or after "SEE", "re-branded as ... ]" (#378), "/" (#305)
###     "also called" (#1019)
### Remove "formerly" from #652 & #1081, domain from #927
### Nested parens (#421)
### Then, clean vectors by splitting by ";", "|", ",", ":"; remove leading & trailing white space
### Remove whole-match duplicates within each vector
### Remove "India" (#351), "US" (#361), "New York State, USA", "Tamil Nadu, India"
###     "Accra, Ghana", "Lagos, Nigeria"
###     but retain in text


## From text, remove everything within parens, within brackets,
##      remove "also here", "also here.", "Also: here.", "Also here:"
### Remove leading and trailing white space



