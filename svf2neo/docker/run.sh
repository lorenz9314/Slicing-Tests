docker run -tid --name neo4j \
	-v "${PWD}/conf:/var/lib/neo4j/conf" \
	-v "${PWD}/logs:/var/lib/neo4j/logs" \
	-v "${PWD}/import:/var/lib/neo4j/import" \
	-v "${PWD}/plugins:/var/lib/neo4j/plugins" \
	-v "${PWD}/scripts:/var/lib/neo4j/scripts" \
	--env 'NEO4J_AUTH=neo4j/Crej2Shraim\' \
	-p 7474:7474 -p 7687:7687 -p 7473:7473 \
	neo4j:latest
