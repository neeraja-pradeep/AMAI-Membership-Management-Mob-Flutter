Integration Document - AMAI

The Figma design for this assignment can be found here:

Web App:- https://www.figma.com/design/Z8f1rr51kyelmzYuqwrF0W/AMAI-Web-Application?node-id=6008-244&p=f&t=5KByjB6ARJNgNw75-0
Mobile App:- figma.com/design/e2nwqmVQusVoQ3iNzyUwuF/AMAI?t=kVzCRjdX7wAYfJKJ-0
The screens provided in the Figma file show:
API Endpoints
All endpoints are non-authenticated and return JSON responses. Use REST GET calls to fetch and render the UI data. The base URL: https://amai.nexogms.com and use the extension given below, test these endpoints in postman to get an idea on the response of each endpoints.

User IDs
Superadmin - 2
Practitioner - 43
HS - 44


Headers -
 dev - {user_id}
If-Modified-Since - Sun, 26 Oct 2025 09:51:00 GMT

Note:- The timestamp mentioned here must be the timestamp fetched from the header of the responses.  


Customer App

Screen : Home  Screen Quick Actions
Aswas Plus
a. Aswas plus card

Swagger link : https://amai.nexogms.com/api/schema/swagger-ui/#/Insurance/insurance_policy_me

Required Fields: policy_status, user_name, policy_number, end_date

POST Endpoint : :https://amai.nexogms.com/api/membership/insurance-policies/me/

b. Nominee Information
Swagger link : https://amai.nexogms.com/api/schema/swagger-ui/#/Insurance%20Nominees/insurance_nominee_me
Required Fields : nominee_name, relationship, contact_number 
GET endpoint : https://amai.nexogms.com/api/membership/insurance-nominees/me/

Screen : Membership renewal 
Choose your membership type
a. Membership

Swagger link : https://amai.nexogms.com/api/schema/swagger-ui/#/membership/membership_digital_products_retrieve

GET endpoint: https://amai.nexogms.com/api/membership/digital-products/2/
ID - 2 

Required Fields:- product_name, base_price

Aswas Plus

Swagger link: https://amai.nexogms.com/api/schema/swagger-ui/#/membership/membership_digital_products_retrieve

GET endpoint: https://amai.nexogms.com/api/membership/digital-products/2/
ID - 2 

Required Fields:- product_name, base_price

b) Proceed to Payment 
Membership

Swagger link : [Initiate Payment] https://amai.nexogms.com/api/schema/swagger-ui/#/Membership/membership_payment_create

POST endpoint: https://amai.nexogms.com/api/membership/membership/payment/

Required Fields : user

Endpoint : [ Verify Payment ] https://amai.nexogms.com/api/schema/swagger-ui/#/Membership/membership_verify_payment

POST endpoint: https://amai.nexogms.com/api/membership/membership/verify/
Required fields :  razorpay_order_id, razorpay_payment_id, razorpay_signature

- Aswas Plus 
Swagger link : [Initiate Payment] https://amai.nexogms.com/api/schema/swagger-ui/#/Insurance/insurance_renewal_create
No Payload
POST endpoint: https://amai.nexogms.com/api/membership/insurance/renewal/

Swagger link : [Verify Payement]
https://amai.nexogms.com/api/schema/swagger-ui/#/Insurance/insurance_renewal_verify_payment
Required Fields : razorpay_order_id, razorpay_payment_id, razorpay_signature
POST endpoint: https://amai.nexogms.com/api/membership/insurance/renewal/verify/







