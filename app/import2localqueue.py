
def get_bookmarks(bookmarks_file):
    with open(bookmarks_file, 'r') as file:
        json_bookmarks = json.load(file)

        jsonpath_expr = parse("$..children[?(@.type=='text/x-moz-place')]")
        moz_places = [match.value for match in jsonpath_expr.find(json_bookmarks)]

        bookmark_list = {}

        for moz_place in moz_places:
            url = moz_place.get('uri', '')
            tags = moz_place.get('tags', '')
            keywords = []

            if url in bookmark_list:
                existing_tags = bookmark_list[url].get('keywords', [])
                keywords.extend(existing_tags)

            if tags:
                tags = tags.split(',')
                keywords.extend(tags)

            bookmark_list[url] = {'keywords': keywords}

        return bookmarks

def push_bookmarks(bookmarks):
    for bookmark in bookmarks:
        url = bookmark['url']
        keywords = bookmark['keywords']

        # Push URL and keywords to the download queue
        download_queue.add(url, keywords)

    # Initialize the downloading process
    download_queue.initialize()


def write_metadata(filename, keywords):

        video = MP4(filename)
        if keywords:
            video["\xa9gen"] = keywords
        video.save()


# Specify the path to your bookmarks JSON file
bookmarks_file = 'bookmarks.json'

def main ():
    # Open the bookmarks file
    bookmarks = get_bookmarks(bookmarks_file)

    # Create an instance of the DownloadQueue class
    download_queue = DownloadQueue(config, notifier)

    for bookmark in bookmarks:
        url = bookmark.get('bookmark_url')
        keywords = bookmark.get('keywords')

        DownloadQueue.add(url, keywords)


if __name__ == "__main__":
    main()
