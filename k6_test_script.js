import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
    stages: [
        { duration: '1m', target: 50 },    // Ramp-up to 10 users over 1 minute
        { duration: '1m', target: 50 },    // Spike to 50 users in 1 minute
        { duration: '5m', target: 50 },    // Stay at 50 users for 5 minutes
    ],
};

export default function () {
    http.get('https://wa-api-pet-service-us.azurewebsites.net/petstorepetservice/v2/pet/info');
	http.get('https://wa-api-order-service-us.azurewebsites.net/petstoreorderservice/v2/store/inventory');
	http.get('https://wa-api-prod-service-us.azurewebsites.net/petstoreproductservice/v2/product/7');
    sleep(1); // Adjust the sleep time as needed
}
