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
preferences change over time. The code used to clean the data and make the
plots that follow is located in r_analysis_plotting.r.

## Results
I was curious to see how the distribution of brands changed over time, so I
aggregated the data for each brand and created a pie chart of the distribution.
These distributions essentially follow my intuition for how I expect them to
behave with Innova consistently being the most popular disc and brands like
Discraft and Discmania gaining more popularity in recent years. An example pie
chart is shown below.
![alt text](https://github.com/tewidis/Reddit-Analytics/blob/master/plots/2019_brand_distribution.png
"2019 Pie Chart")

Using pie charts to evaluate a change over time is difficult, so I created an
animated histogram of the distribution that shows how the distribution changes
each year, shown below. Discraft has grown in popularity immensely in recent
years, consistent with the signing of high-profile players such as Paul McBeth.
![alt text](https://github.com/tewidis/Reddit-Analytics/blob/master/plots/brands.gif
"Animated Histogram")

I was also curious what the popular discs were each year and how
these changed over time, so I created bar charts of the top 25 discs for each
year.
![alt text](https://github.com/tewidis/Reddit-Analytics/blob/master/plots/2019_disc_bar_graph.png
"2019 Top 25 Discs")

Once again, using multiple static bar graphs to view a change over time is
difficult, and I wanted to learn how to create the animated bar charts that are
so popular on /r/dataisbeautiful, so I once again turned to gganimate.
![alt text](https://github.com/tewidis/Reddit-Analytics/blob/master/plots/discs.gif "Most
Popular Discs Animated")

## Conclusion
This project gave me exposure to several new libraries and techniques that will
be useful as I continue to develop my data science skills. While my dataset was
small, the project taught me the difficulties of working with raw text data
from a variety of users. There were numerous spelling mistakes, deleted
comments, and comments unrelated to the purpose of the post that needed to be
cleaned prior to completing any analysis or visualizations.

I found the tidyverse library to be an effective and easy-to-use library for
creating a variety of different plots and was impressed by how clean plots made
with ggplot look without substantial modification. While the functionality of ggplot can be
mimicked using something like matplotlib/seaborn, python
lacks a library that competes with R's gganimate. However, I prefer python's
numerous options for webscraping (BeautifulSoup, PRAW) for
gathering data. I found that using python for scraping and R for
analysis/visualization was an effective workflow that I will likely implement
for future data science projects.
