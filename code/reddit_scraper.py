import praw
import pandas as pd
import configparser

def main():
    # parse the configuration file to get the reddit credentials for the project. client_secret should remain secret, so moving it to a separate, untracked file
    cfg = configparser.ConfigParser();
    cfg.read('/home/twidis/discgolf_analytics/code/credentials.ini');

    reddit = praw.Reddit(user_agent=cfg.get('reddit_credentials', 'user_agent'),
                        client_id=cfg.get('reddit_credentials', 'client_id'),
                        client_secret=cfg.get('reddit_credentials', 'client_secret'));

    # get the id of each post to be analyzed
    post_ids = {'2013': '13wixp',
            '2014': '2fc0a9',
            '2015': '3hwlt4',
            '2016': '581an5',
            '2018': '9bpmke',
            '2019': 'd9kcvu'};

    # loop over the posts, doing a depth first search to get the brand, name, plastic, and run of each disc, then write to a csv
    for ids in post_ids:
        submission = reddit.submission(id=post_ids[ids]);

        submission.comments.replace_more(limit=0);
        comments_dict = dfs_discs(submission.comments);

        df = pd.DataFrame(comments_dict);
        df.to_csv('/home/twidis/discgolf_analytics/data/data' + ids + '.csv', index=False);

def dfs_discs(list_of_discs):
    # define a dict and loop over the comments to populate it with the required data
    comments_dict = { "brand":[], "disc":[], "plastic":[], "run":[], "score":[] };

    for brand in list_of_discs:
        for disc in brand.replies:
            for plastic in disc.replies:
                if not len(plastic.replies) == 0:
                    for run in plastic.replies:
                        comments_dict["brand"].append(brand.body);
                        comments_dict["disc"].append(disc.body);
                        comments_dict["plastic"].append(plastic.body);
                        comments_dict["run"].append(run.body);
                        comments_dict["score"].append(run.score);
                else:
                    comments_dict["brand"].append(brand.body);
                    comments_dict["disc"].append(disc.body);
                    comments_dict["plastic"].append(plastic.body);
                    comments_dict["run"].append([]);
                    comments_dict["score"].append(plastic.score);
    return comments_dict;

if __name__ == "__main__":
    main();
