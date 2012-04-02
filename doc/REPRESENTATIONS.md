# JSON Representations

This document describes the JSON representations for the ResponseSet and Survey models.  The models can be serialized
by calling the `to_json` method.

## ResponseSet

An example of the serialized ResponseSet JSON can be found below. The schema will be coming soon.
 
    /* ResponseSet JSON */
    {
      "uuid"        : "9af6d142-7fac-4ccb-9bca-58a05308a5a7",
      "survey_id"   : "94b3d750-fb63-4540-a1e2-dd7f88be9b4f",
      "created_at"  : "1970-02-04T05:15:30Z",
      "completed_at": "1990-03-06T07:21:42Z"
      "responses": [{
        "uuid"        : "07d72796-ebb2-4be2-91b9-68f5a30a0054",
        "answer_id"   : "9c788711-8373-44d7-b44b-754c31e596a9",
        "question_id" : "376a501b-c32f-49de-b4d7-e28030a2ea94",
        "value"       : "Chimpanzee",
        "created_at"  : "1970-02-04T05:15:30Z",
        "modified_at" : "1990-03-06T07:21:42Z"
      },{
        "uuid"        : "d0467180-e126-44c0-b112-63bb87f0d869",
        "answer_id"   : "86a85d44-9f39-4df9-ae90-da7ff5dbaaf5",
        "question_id" : "6146c103-4a8b-4869-836b-415b8666babe",
        "created_at"  : "1970-02-04T05:16:30Z",
        "modified_at" : "1990-03-06T07:22:42Z"
      }]
    }

## Survey

Example representation and schema coming soon.