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

## Scrape links to list (since number of links per text entry varies) and clean
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

### Add links written out in text (e.g. #266) by searching for domain extensions
### Probably concatenate links to one column

## Extract alternate names from text
for (i in 1:length(p.text)) {
    temp = c()
    if (grepl("(", p.text[i], fixed=T)) {
        temp = append(temp, regmatches(p.text[i],
                                       gregexpr("(?<=\\().*?(?=\\))",
                                                p.text[i], perl=T))[[1]])
    }
    if (grepl("see", p.text[i], fixed=T, ignore.case=T)) {
#        temp = append(temp, )
    }
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



