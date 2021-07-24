
URL=$(cat /tmp/url)
if [ -f /tmp/MID ]; then
  ID=$(cat /tmp/MID)
else
  ID=$1
fi
# echo "Query record: $ID"

[ -z $URL ] && { echo "Error: URL not found"; exit 3; }
[ -z $ID ] && { echo "Error: ID not found"; exit 3; }

curl -s -X GET $URL$ID
