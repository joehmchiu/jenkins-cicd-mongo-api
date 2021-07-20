
URL=$(cat /tmp/url)

if [ -f /tmp/MID ]; then
  ID=$(cat /tmp/MID)
else
  ID=$1
fi

# echo "Update record: $ID"

[ -z $URL ] && { echo "Error: URL not found"; exit 3; }
[ -z $ID ] && { echo "Error: ID not found"; exit 3; }

API=$URL$ID
DT=$(date +'%F %T')
JS='{"name":"Hello World","mobile":"04133888888","email":"hello.world@mail.com","gender":"Female","update":"'$DT'"}'
curl -s -H 'Content-Type: application/json' -X PUT \
    -d "$JS" \
    "$API"
