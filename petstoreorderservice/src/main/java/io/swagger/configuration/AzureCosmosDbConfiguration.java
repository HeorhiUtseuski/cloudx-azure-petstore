package io.swagger.configuration;

import com.azure.data.cosmos.CosmosKeyCredential;
import com.microsoft.azure.spring.data.cosmosdb.config.CosmosDBConfig;
import com.microsoft.azure.spring.data.cosmosdb.repository.config.EnableCosmosRepositories;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableCosmosRepositories
public class AzureCosmosDbConfiguration {
    @Value("${azure.cosmosdb.uri}")
    private String uri;

    @Value("${azure.cosmosdb.key}")
    private String key;

    @Value("${azure.cosmosdb.database}")
    private String dbName;

    @Bean
    public CosmosDBConfig getConfig() {
        CosmosKeyCredential cosmosKeyCredential = new CosmosKeyCredential(key);
        return CosmosDBConfig.builder(uri, cosmosKeyCredential, dbName)
                .build();
    }
}
