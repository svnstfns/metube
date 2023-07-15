import json
from jsonpath_ng import parse
import requests

def get_bookmark_list(bookmark_file):
    """
    Export bookmarks from Firefox browser as a JSON file. Load the JSON file and extract bookmarks (URLs, tags, etc.).
    """
    try:
        with open(bookmark_file, 'r') as file:
            json_bookmarks = json.load(file)

            print("Reading bookmarks...")
            jsonpath_expr = parse("$..children[?(@.type=='text/x-moz-place')]")
            moz_places = [match.value for match in jsonpath_expr.find(json_bookmarks)]

            bookmark_list = {}

            for moz_place in moz_places:
                url = moz_place.get('uri', '')
                tags = moz_place.get('tags')
                keywords = set()

                if url in bookmark_list:
                    existing_tags = bookmark_list[url].get('keywords', set())
                    keywords.update(existing_tags)

                if tags:
                    keywords.update(tags.split(','))

                bookmark_list[url] = {'keywords': keywords}

            return bookmark_list

    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error occurred during queue chunking: {str(e)}")
        return None


def request_download(bookmark):
    """
    Send a request on this machine with the URL and keywords.
    """
    try:
        url = bookmark.get('bookmark_url')
        tags = bookmark.get('tags')

        # javascript:(function(){xhr=new XMLHttpRequest();xhr.open("POST","https://metube.domain.com/add");xhr.send(JSON.stringify({"url":document.location.href,"quality":"best"}));xhr.onload=function(){if(xhr.status==200){alert("Sent to metube!")}else{alert("Send to metube failed. Check the javascript console for clues.")}}})();
        headers = {
            'Content-Type': 'application/json'
        }

        url = f"{url}/add"  # Updated server URL

        data = {
            'url': f"{url}",
            'quality': 'best',  # Updated quality value
            'tags': f"{tags}"
        }
        response = requests.post(url, json=data, headers=headers)

        if response.status_code != 200:
            raise Exception('Request failed with status code: {}'.format(response.status_code))

    except Exception as e:
        to_log(f"An error occurred: {str(e)}")
        # Handle the exception or perform any necessary cleanup/logging

bookmarkfile = 'path/to/file'

def main():
    bookmarklist = get_bookmark_list(bookmark_file)

    for bookmark in bookmarklist:
        request_download(bookmark)

if __name__ == "__main__":
    main()
