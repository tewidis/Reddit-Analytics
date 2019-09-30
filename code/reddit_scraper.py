import praw
import pandas as pd
import configparser

def main():
    cfg = configparser.ConfigParser();
    cfg.read('/home/twidis/discgolf_analytics/code/credentials.ini');

    reddit = praw.Reddit(user_agent=cfg.get('reddit_credentials', 'user_agent'),
                        client_id=cfg.get('reddit_credentials', 'client_id'),
                        client_secret=cfg.get('reddit_credentials', 'client_secret'));

    post_ids = {'2013': '13wixp',
            '2014': '2fc0a9',
            '2015': '3hwlt4',
            '2016': '581an5',
            '2018': '9bpmke',
            '2019': 'd9kcvu'};

    for ids in post_ids:
        submission = reddit.submission(id=post_ids[ids]);

        submission.comments.replace_more(limit=0);
        comments_dict = dfs_discs(submission.comments);

        df = pd.DataFrame(comments_dict);
        df.to_csv('/home/twidis/discgolf_analytics/data/data' + ids + '.csv', index=False);

def dfs_discs(list_of_discs):
    comments_dict = { "brand":[], "disc":[], "plastic":[], "run":[], "score":[] };

    for brand in list_of_discs:
        for disc in brand.replies:
            for plastic in disc.replies:
                if not len(plastic.replies) == 0:
                    for run in plastic.replies:
                        #comments_dict["disc"].append(brand.body + ' ' + disc.body + ' ' + plastic.body + ' ' + run.body);
                        comments_dict["brand"].append(brand.body);
                        comments_dict["disc"].append(disc.body);
                        comments_dict["plastic"].append(plastic.body);
                        comments_dict["run"].append(run.body);
                        comments_dict["score"].append(run.score);
                else:
                    #comments_dict["disc"].append(brand.body + ' ' + disc.body + ' ' + plastic.body);
                    comments_dict["brand"].append(brand.body);
                    comments_dict["disc"].append(disc.body);
                    comments_dict["plastic"].append(plastic.body);
                    comments_dict["run"].append([]);
                    comments_dict["score"].append(plastic.score);
    return comments_dict;

def depth_first_search(full_list):
    #for top_level_comments in full_list:
    queue = list(full_list);
    print(full_list);
    comments = [];

    while queue:
        comment = queue.pop(0);
        comments.append(comment);
        queue[0:0] = comment.replies;

    return comments;

if __name__ == "__main__":
    main();
