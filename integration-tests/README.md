# Integration tests
This folder contains all you need to test if `logstash-exporter` is compatible with certain version of logstash.

## Requirements
You need `docker` and `docker-compose`.

## Execution

### Basic
To test certain logstash version, go to this folder (`integration-tests`) and start logstash container via:
```bash
docker run -it -p 9600:9600 -v $PWD/pipeline-basic.conf:/usr/share/logstash/pipeline/logstash.conf -v $PWD/test.log:/tmp/test.log -e XPACK_MONITORING_ENABLED=false --rm docker.elastic.co/logstash/logstash:7.5.2
```

Then start `logstash-exporter` with default configuration and obtain information about metrics via:
```bash
curl http://localhost:9198/metrics
```

Something similar to the following output must be present on previous output:
```text
logstash_node_plugin_events_out_total{pipeline="main",plugin="file",plugin_id="07080308db2cfbd16a66fd40698946e2d0d2b0e86063a900a579f6d2055cb89e",plugin_type="input"} 1
```

### Filebeat support
To test filebeat support, go to this folder (`integration-tests`) and start logstash container via:
```bash
docker-compose -f docker-compose-filebeat.yml up
```

Then start `logstash-exporter` with default configuration and obtain information about metrics via:
```bash
curl http://localhost:9198/metrics
```

Something similar to the following output must be present on previous output:
```text
logstash_node_plugin_peak_connections_count{pipeline="main",plugin="beats",plugin_id="75409caa45bec593a929307dd6013f749d0cfa2bafd75aacf2142ae7512e6ee6",plugin_type="input"} 1
```
