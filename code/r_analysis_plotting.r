# Load the tidyverse library
library(tidyverse);
library(grid);
library(gridExtra);
library(gganimate);
library(magick);

# Read in the data and convert list to dataframe
df <-
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

df <- do.call(rbind.data.frame, df)

# Convert string years to numerics
df$Year <- as.numeric(df$Year)

# Sort the data
df <- df[order(df$Year, -df$Score),]

# Years to examine
years <- unique(df$Year);

# Sum up the total number of discs per brand
brand_data = aggregate(df$Score ~ Year + Brand, df, sum, na.rm = TRUE)

# Rename score column
colnames(brand_data)[colnames(brand_data)=="df$Score"] <- "Score";

# Clean deleted comments from data
brand_data <- brand_data[brand_data$Brand!="[deleted]",];

# Combine MVP and Axiom (Vectorize this)
for (i in years) {
  if (!identical(filter(brand_data, Year == i & Brand == "Axiom")$Score, integer(0))) {
    brand_data[brand_data$Year == i & brand_data$Brand == "MVP",3] <- filter(brand_data, Year == i & Brand == "MVP")$Score + filter(brand_data, Year == i & Brand == "Axiom")$Score;
  }
}
brand_data$Brand <- str_replace(brand_data$Brand, "MVP", "MVP/Axiom");
brand_data <- na.omit(brand_data[brand_data!="Axiom",]);

# Get all the brands from each year
brands <- unique(brand_data$Brand);

# Make a struct of all the brands, NA if brand not present in given year
all_brands <- data.frame(matrix(0,ncol=2,nrow=length(years)*length(brands)));
colnames(all_brands) <- c("Year", "Brand");
all_brands$Brand <- rep(brands, each=length(years));
all_brands$Year <- rep(years, times=length(brands));
all_brands <- merge(all_brands, brand_data,by=c("Year","Brand"), all=TRUE)

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
  disc_data <- print(head(df[df$Year == i,], n), max.levels=0);
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
  
  # Put both plots on one page
  mypath = file.path("/home", "twidis", "discgolf_analytics", "plots", paste(toString(i),"_summary.pdf", sep=""));
  pdf(file=mypath);
  grid.arrange(pie, bp);
  dev.off();
}

# Select the top n discs of each year
top_25 <- df %>%
  group_by(Year) %>%
  mutate(Rank = rank(-Score, ties.method = "first"),
         Value_rel = Score/Score[Rank==1],
         Value_lbl = paste0(" ", Score)) %>%
  group_by(Disc) %>%
  filter(Rank <= n)

# Making an animated plot
p <- ggplot(top_25, aes(-Rank,Score,fill=Brand)) + 
  geom_col(width=0.8, position="identity") +
  coord_flip() + 
  geom_text(aes(-Rank,y=0,label=str_replace(paste(Plastic, Disc, Run), "\\[\\]", ""),hjust=0)) +
  geom_text(aes(-Rank,y=Score,label=Value_lbl,hjust=0)) + 
  transition_states(Year,4,1) + 
  labs(x="", 
       y="Number of Upvotes", 
       title="/r/discgolf's Disc Preferences", 
       subtitle="Year: {closest_state}",
       font="Quicksand") + 
  ease_aes('linear') +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(size=14),
        axis.ticks = element_blank(),
        plot.title = element_text(face="bold", size=20),
        plot.subtitle = element_text(size=14),
        panel.grid.major.x = element_line(color = "grey1"),
        panel.grid.minor.x = element_line(color = "grey1"));

my_gif <- animate(p, 100, fps=25, duration=20, width=800, height=600);

# Save the gif
mypath = file.path("/home", "twidis", "discgolf_analytics", "plots", "discs.gif");
anim_save(mypath, my_gif)

# Get the distribution of different brands for each year
brands = c("Discmania", "Discraft", "Dynamic Discs", "Innova", "Latitude 64", "Legacy", "Kastaplast", "MVP/Axiom", "Prodigy", "Westside");
brands_reduced = all_brands[all_brands$Brand %in% brands,]
top_brands <- brands_reduced %>%
  group_by(Year) %>%
  mutate(Rank = rank(-Score, ties.method = "first"),
         Value_rel = Score/Score[Rank==1],
         Value_lbl = paste0(" ", Score),
         Value_pct = 100*Score/sum(Score, na.rm=TRUE)) %>%
  group_by(Brand) %>%
  filter(Rank <= 10)
top_brands[is.na(top_brands)] <- 0;

# Making an animated plot
p <- ggplot(top_brands, aes(Brand,Value_pct,fill=Brand)) + 
  geom_col(width=1, position="identity") +
  #geom_text(aes(Rank,y=0,label=Brand,hjust=0)) +
  geom_text(aes(Brand,y=Value_pct,label=as.character(round(Value_pct, digits=2)),hjust=0.5)) + 
  transition_states(Year,4,1) + 
  labs(x="Brand", 
       y="Percentage of Total", 
       title="/r/discgolf's Brand Preferences", 
       subtitle="Year: {closest_state}",
       font="Quicksand") + 
  ease_aes('linear') +
  ylim(0,100) +
  theme(axis.text.y = element_text(size=14),
        axis.text.x = element_text(angle=45, hjust=1, size=14),
        axis.ticks = element_blank(),
        plot.title = element_text(face="bold", size=20),
        plot.subtitle = element_text(size=14),
        panel.grid.major.x = element_line(color = "grey1"),
        panel.grid.minor.x = element_line(color = "grey1"),
        panel.grid.major.y = element_line(color = "grey1"),
        panel.grid.minor.y = element_line(color = "grey1"));

my_gif <- animate(p, 100, fps=25, duration=20, width=800, height=600);

# Save the gif
mypath = file.path("/home", "twidis", "discgolf_analytics", "plots", "brands.gif");
anim_save(mypath, my_gif)