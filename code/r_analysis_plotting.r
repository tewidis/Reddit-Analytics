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

# Sort the data
data <- data[order(data$Year, -data$Score),]

# Sum up the total number of discs per brand
brand_data = aggregate(data$Score ~ Year + Brand, data, sum, na.rm = TRUE)

# Rename score column
colnames(brand_data)[colnames(brand_data)=="data$Score"] <- "Score";

# Clean deleted comments from data
brand_data <- brand_data[brand_data$Brand!="[deleted]",];

# Plot the top n discs
n <- 25;

for (i in c(2013, 2014, 2015, 2016, 2018, 2019)) {
  # Make a pie chart of the distribution of brands
  brand_year <- brand_data[brand_data$Year == i,];
  bp <-
    ggplot(brand_year,
           aes(
             x = "",
             y = Score,
             fill = Brand
           )) + geom_bar(width = 1, stat = "identity")
  
  pie <- bp + coord_polar("y", start = 0)
  
  # Set the output path
  mypath = file.path("/home", "twidis", "discgolf_analytics", "plots", paste(toString(i),"_brand_distribution.pdf", sep=""));
  
  # Save the plot
  pdf(file = mypath);
  
  pie <- pie + labs(title=toString(i), x="Score", y="", fill="Brand");
  
  print(pie);
  
  dev.off();
  
  # Make a bar chart of the top n discs
  disc_data <- print(head(data[data$Year == i,], n), max.levels=0);
  bp <- ggplot(data = disc_data, aes(x=reorder(str_replace(paste(Plastic, Disc, Run), "\\[\\]", ""), -Score), y=Score, fill=as.factor(1:n))) + 
    geom_bar(stat="identity") +
    labs(title=paste("Top ", toString(n), " Discs in ", toString(i)), x="Disc", y="Number")
  
  bp <- bp + guides(fill=FALSE);
  
  bp <- bp + theme(axis.text.x = element_text(angle=45, hjust=1));
  
  # Set the output path
  mypath = file.path("/home", "twidis", "discgolf_analytics", "plots", paste(toString(i),"_disc_bar_graph.pdf", sep=""));
  
  # Save the plot
  pdf(file = mypath);
  
  print(bp);
  
  dev.off();

}
