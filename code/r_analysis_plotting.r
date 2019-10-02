# Load the tidyverse library
library(tidyverse)

# Read in the data and convert list to dataframe
data <-
  lapply(list.files(
    path = "/home/twidis/discgolf_analytics/data",
    pattern = "*.csv",
    full.names = TRUE
  ),
  function(i) {
    df <-
      read.csv(
        i,
        header = FALSE,
        col.names = c("Brand", "Disc", "Plastic", "Run", "Score")
      )
    df$Year <-
      gsub(".csv",
           "",
           gsub("/home/twidis/discgolf_analytics/data/data", "", i))
    return(df)
  })

data <- do.call(rbind.data.frame, data)

# Convert string years to numerics
data$Year <- as.numeric(data$Year)

# Sum up the total number of discs per brand
brand_data = aggregate(data$Score ~ Year + Brand, data, sum, na.rm = TRUE)

# Rename score column
colnames(brand_data)[colnames(brand_data)=="data$Score"] <- "Score";

# Clean deleted comments from data
brand_data <- brand_data[brand_data$Brand!="[deleted]",];

for (i in c(2013, 2014, 2015, 2016, 2018, 2019)) {
  # Make a pie chart of the distribution of brands
  brand_year = brand_data[brand_data$Year == i,];
  bp <-
    ggplot(brand_year,
           aes(
             x = "",
             y = brand_year$Score,
             fill = brand_year$Brand
           )) + geom_bar(width = 1, stat = "identity")
  
  pie <- bp + coord_polar("y", start = 0)
  
  # Set the output path
  # mypath = file.path(paste("/home/twidis/discgolf_analytics/plots/",toString(i),"_brand_distribution.png", sep = ""));
  mypath = file.path("/home", "twidis", "discgolf_analytics", "plots", paste(toString(i),"_brand_distribution.pdf", sep=""));
  
  # Save the plot
  pdf(file = mypath);
  
  print(pie);
  
  dev.off();
}
