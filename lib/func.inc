
function test {
  SNO=$1
  FNO=$2
  ACT=$3
  tmpfile=$4
  testfile=$5
  RNO=$(( ( RANDOM % 100 )  + 1 ))
  echo "[$RNO,$SNO,$FNO]
  if [ $RNO -lt $FNO ]; then
    echo "{\\"$ACT\\":\\"failed\\"}" >> $testfile
  elif [ $RNO -lt $SNO ]; then
    echo "{\\"$ACT\\":$(cat $tmpfile | jq '.status')}" >> $testfile
  else
    echo "{\\"$ACT\\":\\"skip\\"}" >> $testfile
  fi
}

# test $SNO $FNO 'Create' "${tmpfile}" "${testfile}"
