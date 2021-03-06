library(wncaahoopR)
library(readr)
library(magrittr)
library(dplyr)

#n <- nrow(ids)
#for(i in 1:n) {
#  cat("Scraping Data for Team", i, "of", n, paste0("(", ids$team[i], ")"), "\n")
#  schedule <- get_schedule(ids$team[i])
#  roster <- get_roster(ids$team[i])
#  write_csv(roster, paste0("2019-20/rosters/", gsub(" ", "_", ids$team[i]), "_roster.csv"))
#  write_csv(schedule, paste0("2019-20/schedules/", gsub(" ", "_", ids$team[i]), "_schedule.csv"))
#}

### Pull Games
date <- as.Date("2017-03-17")
while(date <= as.Date("2017-05-01")) {
  schedule <- w_get_master_schedule(date)
  if(!is.null(schedule)) {
    if(!dir.exists(paste("2016-17/pbp_logs", date, sep = "/"))) {
      dir.create(paste("2016-17/pbp_logs", date, sep = "/")) 
    }
    write_csv(schedule, paste("2016-17/pbp_logs", date, "schedule.csv", sep = "/"))
    
    n <- nrow(schedule)
    for(i in 1:n) {
      print(paste("Getting Game", i, "of", n, "on", date))
      x <- try(w_get_pbp_game(schedule$game_id[i]))
      
      if(is.data.frame(x)) {
        write_csv(x, paste("2016-17/pbp_logs", date, paste0(schedule$game_id[i], ".csv"), sep = "/"))
      }
    }
  }
  date <- date + 1
}

### Update Master Schedule
date <- as.Date("2017-03-17")
master_schedule <- NULL
while(date <= as.Date("2017-05-01")) {
  schedule <- try(read_csv(paste("2016-17/pbp_logs", date, "schedule.csv", sep = "/")) %>%
                    mutate("date" = date))
  if(class(schedule)[1] != "try-error") {
    write_csv(schedule, paste("2016-17/pbp_logs", date, "schedule.csv", sep = "/"))
    master_schedule <- bind_rows(master_schedule, schedule)
  }
  
  date <- date + 1
}
write_csv(master_schedule, "2016-17/pbp_logs/master_schedule.csv")
