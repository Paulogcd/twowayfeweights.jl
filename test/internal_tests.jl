url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Wolfers%202006/wolfers2006_didtextbook.dta"

use "wolfers2006_didtextbook.dta", clear
twowayfeweights div_rate state year rel_time1, type(feTR) test_random_weights(year) weight(stpop) other_treatments(rel_time2-rel_time16) controls(rel_timeminus1-rel_timeminus9)

    using ReadStatTables
    using Downloads
    using DataFrames

    # For this test, we are going to use the official / original 
    # code snipped used in the original package.
    url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Wolfers%202006/wolfers2006_didtextbook.dta"
    path = Downloads.download(url)
    data = ReadStatTables.readstat(path)
    data = DataFrames.DataFrame(data)

other_treatments = [
    "rel_time2",
    "rel_time3",
    "rel_time4",
    "rel_time5",
    "rel_time6",
    "rel_time7",
    "rel_time8",
    "rel_time9",
    "rel_time10",
    "rel_time11",
    "rel_time12",
    "rel_time13",
    "rel_time14",
    "rel_time15",
    "rel_time16"
]

controls = [
    "rel_timeminus1", 
    "rel_timeminus2", 
    "rel_timeminus3", 
    "rel_timeminus4", 
    "rel_timeminus5", 
    "rel_timeminus6", 
    "rel_timeminus7", 
    "rel_timeminus8", 
    "rel_timeminus9"
]

data = data
Y = "div_rate"
G = "state"
T = "year"
D = "rel_time1"
type = "feTR"
test_random_weights = "year"
weights = data.stpop
other_treatments = other_treatments
controls = controls

    twowayfeweights(
        data = data,
        Y = "div_rate", 
        G = "state",
        T = "year",
        D = "rel_time1",
        type = "feTR",
        test_random_weights = "year",
        weights = data.stpop,
        other_treatments = other_treatments,
        controls = controls)



twowayfeweights Y G T D [D0], type(string)
  [summary_measures test_random_weights(varlist)
  controls(varlist) other_treatments(varlist) weight(varlist) path(string)]