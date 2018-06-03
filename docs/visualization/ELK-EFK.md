# ELK集成

Kubernetes、Kafka（消息系统）

日志收集：Logstash、Filebeat

全文搜索引擎：Kibana

日志可视化：CAdvisor、InfluxDB与Grafana； 

```
问题：
1. Kubernetes如何实现集群日志收集？
方案一，日志保留在容器内部，需要时从中读取，缺点是没能集中管理。
方案二，日志挂载到本地，通过Logstash采集日志并送入Elasticsearch进行存储，缺点是难以建立容器与日志的关系。
方案三，直接将日志写入标准输出，然后Logstash通过Docker的log-driver捕获日志，通过Kibana来分析日志，缺点是log-driver取走了日志，Docker不能实时查看日志，但可以依靠tail等工具实时查看日志文件变动。
```
