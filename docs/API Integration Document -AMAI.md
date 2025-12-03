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
Memberships
a) Memberships 
 Swagger link: https://amai.nexogms.com/api/schema/swagger-ui/#/membership/membership_memberships_list

 Required fields:- is_active, user_first_name, membership_number, end_date

 POST endpoint: https://amai.nexogms.com/api/membership/memberships/{user_id}/

b) Payment Reciepts

 Swagger link: https://amai.nexogms.com/api/schema/swagger-ui/#/Payments/payment_list

 POST Endpoint : https://amai.nexogms.com/api/payments/payment/



