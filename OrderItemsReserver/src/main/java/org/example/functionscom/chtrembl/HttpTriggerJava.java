package org.example.functionscom.chtrembl;

import java.util.*;
import com.microsoft.azure.functions.annotation.*;
import com.microsoft.azure.functions.*;
import org.example.functionscom.chtrembl.model.Order;

public class HttpTriggerJava {
    @FunctionName("OrderHistorySave")
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

        if (request.getBody().isPresent()) {
            target.setValue(request.getBody().get());
        }

        return request.createResponseBuilder(HttpStatus.OK).body("Hello, " + sessionId).build();
    }
}
