# Load the tidyverse library
library(tidyverse);
library(grid);
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

# Sum up the total number of discs per brand
brand_data = aggregate(df$Score ~ Year + Brand, df, sum, na.rm = TRUE)

# Rename score column
colnames(brand_data)[colnames(brand_data)=="df$Score"] <- "Score";

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
  mutate(Rank = rank(-Score),
         Value_rel = Score/Score[Rank==1],
         Value_lbl = " Score") %>%
  group_by(Disc) %>%
  filter(Rank <= n)

# Making an animated plot
p <- ggplot(top_25, aes(-Rank,Value_rel,fill=Disc)) + 
  geom_col(width=0.8, position="identity") +
  coord_flip() + 
  geom_text(aes(-Rank,y=0,label=str_replace(paste(Plastic, Disc, Run), "\\[\\]", ""),hjust=0)) +
  geom_text(aes(-Rank,y=Value_rel,label=Value_lbl,hjust=0)) + 
  theme_minimal() + 
  theme(legend.position = "none", axis.title = element_blank()) +
  transition_states(Year,4,1) + 
  labs(x="Disc", y="Number", title="Year: {closest_state}") + 
  ease_aes('cubic-in-out');

my_gif <- animate(p, 100, fps=25, duration=20, width=800, height=600);

# Save the gif
mypath = file.path("/home", "twidis", "discgolf_analytics", "plots", "discs.gif");
anim_save(mypath, my_gif)