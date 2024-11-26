import http from 'k6/http';
import { check, sleep } from 'k6';
import { htmlReport } from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js";

export let options = {
    vus: 1,
    duration: '10s',
};

export default function () {
    const BASE_URL = 'http://192.168.254.203/';
    let res = http.get(BASE_URL);
    check(res, {
        'homepage status is 200': (r) => r.status === 200,
    });
    sleep(1);
}

export function handleSummary(data) {
    return {
        "/performace_testing_script/summary.html": htmlReport(data),
    };
}