package com.chtrembl.petstore.order.repository;

import com.chtrembl.petstore.order.model.Product;
import com.microsoft.azure.spring.data.cosmosdb.repository.CosmosRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends CosmosRepository<Product, String> {
    @Override
    List<Product> findAll();
}
