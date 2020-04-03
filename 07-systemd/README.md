07-systemd
===

# Kafka
В `provision` прописан Ansible сценарий `site.yml`, который при помощи роли `kafka-server` устанавливает Zookeeper и Kafka из Confluent сборки.
```bash
~/Projects/self/otus-linux/07-systemd master*
❯ vagrant up
...
❯ vagrant ssh

[vagrant@host1 vagrant]$ systemctl status zookeeper
● zookeeper.service - Zookeeper Service
   Loaded: loaded (/etc/systemd/system/zookeeper.service; enabled; vendor preset: disabled)
  Drop-In: /etc/systemd/system/zookeeper.service.d
           └─50-CPUQuota.conf, 50-MemoryLimit.conf, 50-TasksMax.conf
   Active: active (running) since Fri 2020-04-03 16:58:18 UTC; 31s ago
  Process: 17175 ExecStop=/usr/bin/zookeeper-server-stop (code=exited, status=0/SUCCESS)
  Process: 17184 ExecStart=/usr/bin/zookeeper-server-start -daemon /etc/kafka/zookeeper.properties (code=exited, status=0/SUCCESS)
 Main PID: 17189 (java)
    Tasks: 22 (limit: 200)
   Memory: 55.0M (limit: 500.0M)
   CGroup: /system.slice/zookeeper.service
           └─17189 java -Xmx512M -Xms512M -server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+DisableExplicitGC -Djava....

Apr 03 16:58:18 host1 systemd[1]: Stopped Zookeeper Service.
Apr 03 16:58:18 host1 systemd[1]: Starting Zookeeper Service...
Apr 03 16:58:18 host1 systemd[1]: Started Zookeeper Service.

[root@vagrant vagrant]$ systemctl status kafka
● kafka.service - Apache Kafka - broker
   Loaded: loaded (/etc/systemd/system/kafka.service; enabled; vendor preset: disabled)
  Drop-In: /etc/systemd/system/kafka.service.d
           └─50-CPUQuota.conf, 50-MemoryLimit.conf, 50-TasksMax.conf
   Active: active (running) since Fri 2020-04-03 16:58:22 UTC; 31s ago
     Docs: http://docs.confluent.io/
 Main PID: 17347 (java)
    Tasks: 66 (limit: 200)
   Memory: 243.7M (limit: 1000.0M)
   CGroup: /system.slice/kafka.service
           └─17347 java -Xmx1G -Xms1G -server -XX:MetaspaceSize=96m -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:G1HeapRe...

Apr 03 16:58:25 host1 kafka-server-start[17347]: [2020-04-03 16:58:25,449] INFO Session establishment complete on server host1/127.0.0.1:2181, sess...entCnxn)
Apr 03 16:58:25 host1 kafka-server-start[17347]: [2020-04-03 16:58:25,450] INFO zookeeper state changed (SyncConnected) (org.I0Itec.zkclient.ZkClient)
Apr 03 16:58:25 host1 kafka-server-start[17347]: [2020-04-03 16:58:25,528] INFO Will not load MX4J, mx4j-tools.jar is not in the classpath (kafka.u...Loader$)
Apr 03 16:58:25 host1 kafka-server-start[17347]: [2020-04-03 16:58:25,548] INFO Creating /brokers/ids/1 (is it secure? false) (kafka.utils.ZKCheckedEphemeral)
Apr 03 16:58:25 host1 kafka-server-start[17347]: [2020-04-03 16:58:25,554] INFO Result of znode creation is: OK (kafka.utils.ZKCheckedEphemeral)
Apr 03 16:58:25 host1 kafka-server-start[17347]: [2020-04-03 16:58:25,555] INFO Registered broker 1 at path /brokers/ids/1 with addresses: PLAINTEX...ZkUtils)
Apr 03 16:58:25 host1 kafka-server-start[17347]: [2020-04-03 16:58:25,556] WARN No meta.properties file under dir /var/lib/kafka/meta.properties (k...ckpoint)
Apr 03 16:58:25 host1 kafka-server-start[17347]: [2020-04-03 16:58:25,647] INFO Kafka version : 0.10.1.1-cp1 (org.apache.kafka.common.utils.AppInfoParser)
Apr 03 16:58:25 host1 kafka-server-start[17347]: [2020-04-03 16:58:25,647] INFO Kafka commitId : 75b3f3b7b5a1782b (org.apache.kafka.common.utils.Ap...oParser)
Apr 03 16:58:25 host1 kafka-server-start[17347]: [2020-04-03 16:58:25,647] INFO [Kafka Server 1], started (kafka.server.KafkaServer)
Hint: Some lines were ellipsized, use -l to show in full.

[vagrant@host1 vagrant]$ systemd-cgtop
Path                                                                                                                   Tasks   %CPU   Memory  Input/s Output/s

/                                                                                                                         86    1.3  1014.8M        -        -
/user.slice                                                                                                                8    0.8   107.9M        -        -
/system.slice                                                                                                              -    0.3   307.5M        -        -
/system.slice/kafka.service                                                                                                1    0.2   247.8M        -        -
/system.slice/zookeeper.service                                                                                            1    0.2    56.1M        -        -
/system.slice/rsyslog.service                                                                                              1    0.0   144.0K        -        -
```
