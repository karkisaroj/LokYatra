const String apiBaseUrl="https://localhost:7200";

//below are endpoints paths
const String loginEndpoint="/api/User/login";
const String registerEndpoint="api/User/createUser";
const String getUsersEndpoint="api/User/getUser";

const Map<String,String> headers={
  "Content-Type":"application/json",
  "Accept":"application/json",
};

const Duration connectTimeout=Duration(seconds: 10);
const Duration receiveTimeout=Duration(seconds: 10);
const Duration sendTimeout=Duration(seconds: 10);