// Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/encoding;
import ballerina/http;
import ballerina/test;

listener Listener simpleResourceListener = new(9092);

@test:Config {
    groups: ["listener", "unit"]
}
function testShortHandQueryResult() returns @tainted error? {
    string document = getGeneralNotationDocument();
    json payload = {
        query: document
    };
    json expectedPayload = {
        data: {
            name: "James Moriarty",
            birthdate: "15-05-1848"
        }
    };
    http:Client httpClient = new("http://localhost:9092/graphql");
    http:Request request = new;
    request.setPayload(payload);

    json actualPayload = <json> check httpClient->post("/", request, json);
    test:assertEquals(actualPayload, expectedPayload);
}

@test:Config {
    groups: ["listener", "unit"]
}
function testGetRequestResult() returns @tainted error? {
    string document = "query getPerson { profile(id: 1) { address { city } } }";
    string encodedDocument = check encoding:encodeUriComponent(document, "UTF-8");
    json expectedPayload = {
        data: {
            profile: {
                address: {
                    city: "Albuquerque"
                }
            }
        }
    };
    http:Client httpClient = new("http://localhost:9095");
    http:Request request = new;

    string path = "/graphql?query=" + encodedDocument;
    json actualPayload = <json> check httpClient->get(path, request, json);
    test:assertEquals(actualPayload, expectedPayload);
}

service /graphql on simpleResourceListener {
    isolated resource function get name() returns string {
        return "James Moriarty";
    }

    isolated resource function get birthdate() returns string {
        return "15-05-1848";
    }
}
