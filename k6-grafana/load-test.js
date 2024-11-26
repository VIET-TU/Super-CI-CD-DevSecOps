import http from "k6/http";
import { check, group, sleep } from "k6";
import { SharedArray } from "k6/data";

export let options = {
  stages: [
    { duration: "10s", target: 50 }, 
    { duration: "1m", target: 500 }, 
    { duration: "1m", target: 100 }, 
    { duration: "1m", target: 0 }, 
  ],
  thresholds: {
    http_req_duration: ["p(95)<800"],
    "http_req_duration{name:PublicCrocs}": ["avg<500"], 
    http_req_failed: ["rate<0.01"], 
  },
};

export default function () {
  group("Load test group", () => {
    // Tạo mới một resource
    let res = http.post(
      "http://192.168.254.203:3000/post",
      JSON.stringify({
        title: "First Post",
        content: "The first post made",
      }),
      {
        headers: {
          "Content-Type": "application/json",
        },
        tags: { name: "CreateResource" },
      }
    );
    check(res, {
      "status is 201": (r) => r.status === 201,
      "resource created": (r) => r.json("id") !== "",
    });
    let resourceId = res.json("id");
    sleep(1);

    // Xem chi tiết resource
    res = http.get(`http://192.168.254.203:3000/post/${resourceId}`, {
      tags: { name: "GetResource" },
    });
    check(res, {
      "status is 200": (r) => r.status === 200,
      "resource id matches": (r) => r.json("id") === resourceId,
    });
    sleep(1);

    // Cập nhật resource
    res = http.patch(
      `http://192.168.254.203:3000/post/${resourceId}`,
      JSON.stringify({
        title: "Updated Resource",
        content: "Updated value",
      }),
      {
        headers: {
          "Content-Type": "application/json",
        },
        tags: { name: "UpdateResource" },
      }
    );
    check(res, {
      "status is 200": (r) => r.status === 200,
      "resource updated": (r) => r.json("name") === "Updated Resource",
    });
    sleep(1);

    // Xóa resource
    // http://192.168.254.203:3000/post
    res = http.del(`http://192.168.254.203:3000/post/${resourceId}`, null, {
      headers: {
        "Content-Type": "application/json",
      },
      tags: { name: "DeleteResource" },
    });
    check(res, {
      "status is 204": (r) => r.status === 204,
    });
    sleep(1);
  });
}
