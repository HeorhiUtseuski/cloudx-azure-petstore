import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
    stages: [
        { duration: '1m', target: 2 },    // Ramp-up to 10 users over 1 minute
        { duration: '1m', target: 10 },    // Spike to 50 users in 1 minute
        { duration: '1m', target: 15 },    // Stay at 50 users for 5 minutes
    ],
};

export default function () {
    http.get(`https://${__ENV.ORDER_SERVICE_HOST}/petstoreorderservice/v2/store/inventory`);
    http.get(`https://${__ENV.PET_SERVICE_HOST}/petstorepetservice/v2/pet/info`);
	http.get(`https://${__ENV.PRODUCT_SERVICE_HOST}/petstoreproductservice/v2/product/7`);

    sleep(1); // Adjust the sleep time as needed
}
