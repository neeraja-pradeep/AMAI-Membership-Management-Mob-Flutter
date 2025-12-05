Integration Document - AMAI

The Figma design for this assignment can be found here:

Web App:- https://www.figma.com/design/Z8f1rr51kyelmzYuqwrF0W/AMAI-Web-Application?node-id=6008-244&p=f&t=5KByjB6ARJNgNw75-0
Mobile App:- figma.com/design/e2nwqmVQusVoQ3iNzyUwuF/AMAI?t=kVzCRjdX7wAYfJKJ-0
The screens provided in the Figma file show:
API Endpoints
All endpoints are non-authenticated and return JSON responses. Use REST GET calls to fetch and render the UI data. The base URL: https://amai.nexogms.com and use the extension given below, test these endpoints in postman to get an idea on the response of each endpoints.

User IDs
Superadmin - 2


Headers -
 dev - {user_id}
If-Modified-Since - Sun, 26 Oct 2025 09:51:00 GMT

Note:- The timestamp mentioned here must be the timestamp fetched from the header of the responses.  


Customer App

Screen : Login 
a) Login
Endpoint:
https://amai.nexogms.com/api/schema/swagger-ui/#/Authentication/auth_login

POST endpoint: https://amai.nexogms.com/api/accounts/login/

payload:{
  "email": "cijo7@test.com",
    "password": "admin"
}


Screen : Forget Password
a) Send otp
Endpoint:
https://amai.nexogms.com/api/schema/swagger-ui/#/Authentication/auth_send_otp

POST endpoint: https://amai.nexogms.com/api/auth/otp-signin/

Payload:

{
    "phone_number":"+919497883832"
}

a) Verify otp and change password
Endpoint:
https://amai.nexogms.com/api/schema/swagger-ui/#/Authentication/auth_verify_otp

POST endpoint: https://amai.nexogms.com/api/auth/otp-signin/

Payload:

{
    "phone_number":"+919497883832",
    "otp_code":"521981",
    "new_password":"adminroot"
}






Screen : Registration 
a) Registration Form 1
Endpoint:
https://amai.nexogms.com/api/schema/swagger-ui/#/Membership/membership_register

Required fields:- 

For Practitioner:- membership_type[student, practitioner, house_surgeon, honorary], first_name, email, password,  phone, wa_phone, date_of_birth, gender, blood_group, medical_council_state,   medical_council_no, central_council_no, ug_college, zone_id, professional_details[], academic_details[]

For example:- "professional_details":["test","tets2"],



For House Surgeon:- membership_type[student, practitioner, house_surgeon, honorary], first_name, email, password,  phone, wa_phone, date_of_birth, gender, blood_group, provisional_reg_no, medical_council_state, council_district_no, zone_id,


For Students:- membership_type[student, practitioner, house_surgeon, honorary], first_name, email, password,  phone, wa_phone, date_of_birth, gender, institution_name, bams_start_year blood_group, 


POST endpoint:https://amai.nexogms.com/api/membership/register/

b) Registration Form 2 -  Address
Endpoint:
https://amai.nexogms.com/api/schema/swagger-ui/#/accounts/accounts_addresses_create

Required fields:- address_line1(House No. / Building Name), address_line2(Street / Locality / Area), city(Post Office), postal_code(Post Code), country(Country), state(State), district(District), type(apta, communications, permanent)
Post endpoint:https://amai.nexogms.com/api/accounts/addresses/

b) Registration Form 3 -  Documents
Endpoint:
https://amai.nexogms.com/api/schema/swagger-ui/#/membership/membership_application_documents_create

Required Fields: application, document_file, document_type 

Post endpoint:https://amai.nexogms.com/api/membership/application-documents/

c) Registration payment 

Endpoint : [Initiate Payment] https://amai.nexogms.com/api/schema/swagger-ui/#/Membership/membership_payment_create_2
POST api/membership/membership/register/payment/

Required Fields : user

Endpoint : [ Verify Payment ] https://amai.nexogms.com/api/schema/swagger-ui/#/Membership/membership_verify_registration_payment

POST api/membership/membership/register/verify/ 

Required fields :  razorpay_order_id, razorpay_payment_id, razorpay_signature

