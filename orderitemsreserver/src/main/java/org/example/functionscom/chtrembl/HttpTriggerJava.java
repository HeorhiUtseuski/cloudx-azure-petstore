package org.example.functionscom.chtrembl;

import java.util.*;
import com.microsoft.azure.functions.annotation.*;
import com.microsoft.azure.functions.*;
import org.example.functionscom.chtrembl.model.Order;

public class HttpTriggerJava {
    @FunctionName("OrderHistorySave")
    @StorageAccount("AzureWebJobsStorage")
    public HttpResponseMessage orderHistory(
            @HttpTrigger(
                    name = "req",
                    methods = {HttpMethod.GET, HttpMethod.POST},
                    authLevel = AuthorizationLevel.ANONYMOUS,
                    route = "{sessionId}"
            ) HttpRequestMessage<Optional<Order>> request,
            @BindingName("sessionId") String sessionId,
            @BlobInput(
                    name = "source",
                    path = "archive/{sessionId}.json"
            ) Optional<Order> source,
            @BlobOutput(
                    name = "target",
                    path = "archive/{sessionId}.json"
            ) OutputBinding<Order> target,
            final ExecutionContext context) {
        context.getLogger().info("Java HTTP trigger processed a request.");

        int countBefore = source.map(order -> order.getProducts().size()).orElse(0);
        int countAfter = request.getBody().map(order -> order.getProducts().size()).orElse(0);

        if (request.getBody().isPresent()) {
            target.setValue(request.getBody().get());
        }

        String resultTemplate = "Result for sessionId[%s]: count products before [%d] products after [%d]";
        return request.createResponseBuilder(HttpStatus.OK).body(resultTemplate.formatted(
                sessionId, countBefore, countAfter
        )).build();
    }
}
