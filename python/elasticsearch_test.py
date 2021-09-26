# coding: utf8

# 操作es

import json

from elasticsearch import Elasticsearch

# es = aes.Connection(
#     host='192.168.9.74',
#     port='9002',
# )
syName = 'filebeat-7.0.1-2019.05.06-000001'

es = Elasticsearch(hosts='172.30.1.35')
esGet = es.indices.get(index=syName)
print(esGet)
# print(type(esGet))