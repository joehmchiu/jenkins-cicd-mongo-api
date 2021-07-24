import pytest
import re, json

testfile='/tmp/test-results'
results = open(testfile, 'r').read().splitlines()

arr = []

for l in results:
    var = json.loads(l)
    for h in var.items():
        arr.append(h)

print(arr)

@pytest.mark.parametrize(
    "key,val",
    arr,
)
def test_equal(key, val):
    assert val == 'ok'
