package com.chtrembl.petstore.order.repository;

import com.chtrembl.petstore.order.model.Order;
import com.microsoft.azure.spring.data.cosmosdb.repository.CosmosRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OrderRepository extends CosmosRepository<Order, String> {
    Optional<Order> findById(String id);
}
