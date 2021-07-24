
MF=/tmp/MID
URL=$(cat /tmp/url)
[ -z $URL ] && { echo "Error: URL not found"; exit 3; }

API=$URL
DT=$(date +'%F %T')
JS='{"name":"Fish Banana","mobile":"0123456789","email":"fish.banana@mail.com","gender":"Male","created":"'$DT'"}'
RET=$(curl -s -H 'Content-Type: application/json' -X POST \
    -d "$JS" \
    "$API")
echo $RET
MID=$(echo $RET | jq '.id' | sed 's/"//g')

echo $MID > $MF
# echo "Stored $MID to $MF"
