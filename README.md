# /r/disgolf User Preferences Analysis
> Analyzing user disc and brand preferences from reddit.com/r/discgolf

Every year (except 2017), /r/discgolf surveys its users to find what discs, brands, and
plastics are most popular among its subscribers. These posts can be found at
the following links:
* [2013](reddit.com/r/discgolf/comments/13wixp)
* [2014](reddit.com/r/discgolf/comments/2fc0a9)
* [2015](reddit.com/r/discgolf/comments/3hwlt4)
* [2016](reddit.com/r/discgolf/comments/581an5)
* [2018](reddit.com/r/discgolf/comments/9bpmke)
* [2019](reddit.com/r/discgolf/comments/d9kcvu)

I was curious how users' preferences changed over time as professional
sponsorships change and new discs are released. I viewed this project as a
chance to practice webscraping and creating static and dynamic data
visualizations.

## Scraping /r/discgolf
In order to gather the required data, I wrote a python script
(reddit_scraper.py) using the Python Reddit API Wrapper (PRAW) library that
scrapes all the comments from each year's post. Expanding this script to gather
future posts is as simple as appending the unique string of the post to the
post_ids dictionary. My scraper performs a depth-first search on the comment
tree to transform the data into a pandas dataframe with the necessary
information for analysis and visualization.

## Visualizing the Data
I've heard so many good things about using the tidyverse library in R for data transformation, cleaning,
and visualization, so I decided to take this project as an opportunity to learn
and practice R. I used dplyr, ggplot, and gganimate to read and transform the
data and create aesthetically pleasing visualizations that show how users'
preferences change over time.

## Results

## Conclusion
I found the tidyverse library to be an effective and easy-to-use library for
creating any number of plots.
