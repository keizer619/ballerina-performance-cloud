// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/log;

listener http:Listener securedEP = new(9090, {
    httpVersion: "2.0",
    secureSocket:  {
        key: {
            path: "./security/ballerinaKeystore.p12",
            password: "ballerina"
        }
    }
});

final http:Client nettyEP = check new("http://netty:8688");

service /passthrough on securedEP {
    resource function post .(http:Caller caller, http:Request clientRequest) {
        http:Response|http:ClientError response = nettyEP->forward("/service/EchoService", clientRequest);
        if (response is http:Response) {
            error? result = caller->respond(response);
        } else {
            log:printError("Error at h2_h1c_passthrough", 'error = response);
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(response.message());
            error? result = caller->respond(res);
        }
    }
}
