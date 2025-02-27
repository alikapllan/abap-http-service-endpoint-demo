# Demo: ABAP HTTP Service Endpoint for Creating Sales Orders

I came across this interesting topic again, thanks to [Software-Heroes](https://software-heroes.com/en/sap). In my opinion, this approach is highly beneficial for non-complex integration scenarios.

The original article, [Software-Heroes: BTP - HTTP Service](https://software-heroes.com/en/blog/btp-http-service-endpoint), explains the concept and implementation process very well.

## Overview
In our SAP S/4HANA 2023 On-Premise system, I implemented an HTTP service that allows sales order creation via an ABAP-based HTTP endpoint with the BAPI 'BAPI_SALESORDER_CREATEFROMDAT2'.  

If you’re new to this BAPI, you may find [this video](https://www.youtube.com/watch?v=qUOiOYBQ3Rw&t=1842s&ab_channel=SathishReddy) helpful in understanding how it works and is triggered.  

The service:  
- Accepts JSON payload.  
- Deserializes it into an ABAP structure.  
- Dynamically sets X fields based on provided values.  

### For example you can see how I test the service via Postman and the result that Sales Order created
-> under **Authorization** tab I selected **'Basic Auth'** and provided my SAP credentials not to get - 401 Unauthorized error.
![image](https://github.com/user-attachments/assets/17e58d14-6bb7-4417-a7a3-406aac60072c)

### Created Sales Order
![image](https://github.com/user-attachments/assets/8592f23e-cd9c-4340-8206-a657334db6a3)

### Example JSON Payload in Postman
```json
{
    "order_header_in": {
        "doc_type": "ZOR",
        "sales_org": "1010",
        "distr_chan": "10",
        "division": "00",
        "req_date_h": "20250224",
        "purch_no_c": "TEST"
    },
    "order_items_in": [
        {
            "itm_number": "000010",
            "material": "000000000050100006",
            "plant": "1010",
            "target_qty": 1.0,
            "target_qu": "KG"
        }
    ],
    "order_partners": [
        {
            "partn_role": "AG",
            "partn_numb": "0001000001"
        },
        {
            "partn_role": "WE",
            "partn_numb": "0001000001"
        }
    ],
    "order_schedules_in": [
        {
            "itm_number": "000010",
            "req_date": "20250224",
            "req_qty": 1.0
        }
    ],
    "order_conditions_in": [
        {
            "itm_number": "000010",
            "cond_type": "PR00",
            "cond_value": 1.0
        }
    ]
}
```
