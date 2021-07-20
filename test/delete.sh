
MF=/tmp/MID
URL=$(cat /tmp/url)
if [ -f $MF ]; then
  ID=$(cat /tmp/MID)
else
  ID=$1
fi

[ -z $URL ] && { echo "Error: URL not found"; exit 3; }
[ -z $ID ] && { echo "Error: ID not found"; echo "Usage: sh delete.sh [Record ID]"; exit 3; }

# echo "Delete record: $ID"

RES=$(curl -s -X DELETE $URL$ID)
echo $RES

MSG=$(echo $RES | jq '.status' | sed 's/"//g')

[ "$MSG" = "ok" ] && rm -f $MF

