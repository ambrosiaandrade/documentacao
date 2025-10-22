docker-compose down -v
docker network prune
docker-compose up --build

## confluentinc/cp-kafka:

1. Listar tópicos existentes
```bash
docker exec -it kafka /usr/bin/kafka-topics --bootstrap-server localhost:9092 --list
```
✔️ Lista todos os tópicos criados no broker.

🧪 2. Criar um novo tópico
```bash
docker exec -it kafka /usr/bin/kafka-topics --bootstrap-server localhost:9092 --create --topic meu-topico --partitions 3 --replication-factor 1
```
✔️ Cria o tópico meu-topico com 3 partitions e fator de replicação 1 (em ambiente local, 1 é suficiente).

🔎 3. Obter detalhes de um tópico
```bash
docker exec -it kafka /usr/bin/kafka-topics --bootstrap-server localhost:9092 --describe --topic test-topic
```
✔️ Mostra informações sobre partições, líderes, réplicas e ISR (in-sync replicas).

🗑️ 4. Deletar um tópico
```bash
docker exec -it kafka /usr/bin/kafka-topics --bootstrap-server localhost:9092 --delete --topic meu-topico
```
⚠️ Só funciona se delete.topic.enable=true estiver configurado no Kafka. Cuidado: não tem confirmação!

📥 5. Produzir mensagens (modo texto interativo)
```bash
docker exec -it kafka /usr/bin/kafka-console-producer --bootstrap-server localhost:9092 --topic meu-topico
```
📨 Tudo que você digitar vai ser enviado como mensagens Kafka (digite e pressione Enter).

📤 6. Consumir mensagens
```bash
docker exec -it kafka /usr/bin/kafka-console-consumer --bootstrap-server localhost:9092 --topic test-topic --from-beginning
```
✔️ Lê todas as mensagens do tópico desde o início.

👥 7. Ver grupos de consumidores
```bash
docker exec -it kafka /usr/bin/kafka-consumer-groups --bootstrap-server localhost:9092 --list
```
✔️ Mostra todos os grupos de consumidores registrados.

🔍 8. Ver status de um grupo de consumidores
```bash
docker exec -it kafka /usr/bin/kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group meu-grupo
```
✔️ Mostra lag, partições e offsets consumidos por um grupo específico.

⏪ 9. Redefinir offset de um grupo
```bash
docker exec -it kafka /usr/bin/kafka-consumer-groups --bootstrap-server localhost:9092 --group meu-grupo --topic meu-topico --reset-offsets --to-earliest --execute
```
✔️ Reposiciona o grupo de consumidores para o início do tópico.

🔄 10. Testar performance com producer
```bash
docker exec -it kafka /usr/bin/kafka-producer-perf-test --topic meu-topico --num-records 1000 --record-size 100 --throughput -1 --producer-props bootstrap.servers=localhost:9092
```
📊 Envia 1000 mensagens de 100 bytes para medir desempenho do Kafka Producer.

