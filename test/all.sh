
URL=$(cat /tmp/url)
[ -z $URL ] && { echo "Error: URL not found"; exit 3; }

# echo "List all record"
curl -s -X GET $URL
