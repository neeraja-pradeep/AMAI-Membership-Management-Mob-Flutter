{
	"info": {
		"_postman_id": "03d9f04a-2403-45be-8975-80c6b6a413e2",
		"name": "AMAI",
		"schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
		"_exporter_id": "45892781",
		"_collection_link": "https://martian-moon-968149.postman.co/workspace/My-Workspace~638a0b2f-d5c6-4466-8a07-5321c65bdb22/collection/45892781-03d9f04a-2403-45be-8975-80c6b6a413e2?action=share&source=collection_link&creator=45892781"
	},
	"item": [
		{
			"name": "login",
			"request": {
				"method": "POST",
				"header": [
					{
						"key": "dev",
						"value": "1",
						"type": "text"
					}
				],
				"body": {
					"mode": "raw",
					"raw": "{\r\n     \"email\": \"admin@amai.com\",\r\n  \"password\": \"admin\"\r\n\r\n}",
					"options": {
						"raw": {
							"language": "json"
						}
					}
				},
				"url": {
					"raw": "https://amai.nexogms.com/api/accounts/login/",
					"protocol": "https",
					"host": [
						"amai",
						"nexogms",
						"com"
					],
					"path": [
						"api",
						"accounts",
						"login",
						""
					]
				}
			},
			"response": []
		},
		{
			"name": "register",
			"request": {
				"method": "POST",
				"header": [
					{
						"key": "dev",
						"value": "1",
						"type": "text",
						"disabled": true
					}
				],
				"body": {
					"mode": "formdata",
					"formdata": [
						{
							"key": "email",
							"value": "cijo2@test.com",
							"type": "text"
						},
						{
							"key": "password",
							"value": "admin",
							"type": "text"
						},
						{
							"key": "first_name",
							"value": "Cijo",
							"type": "text"
						},
						{
							"key": "last_name",
							"value": "George",
							"type": "text"
						},
						{
							"key": "phone",
							"value": "1234567891",
							"type": "text"
						},
						{
							"key": "user_type",
							"value": "student",
							"type": "text"
						},
						{
							"key": "membership_type",
							"value": "student",
							"type": "text"
						},
						{
							"key": "zone_id",
							"value": "1",
							"type": "text"
						},
						{
							"key": "address",
							"value": "{\"address_line1\":\"123 Main St\",\"city\":\"Mumbai\",\"state\":\"Maharashtra\",\"postal_code\":\"400001\",\"country\":\"India\"}",
							"type": "text",
							"disabled": true
						}
					]
				},
				"url": {
					"raw": "{{amai}}/api/membership/register/",
					"host": [
						"{{amai}}"
					],
					"path": [
						"api",
						"membership",
						"register",
						""
					]
				}
			},
			"response": []
		},
		{
			"name": "application document",
			"protocolProfileBehavior": {
				"disableBodyPruning": true
			},
			"request": {
				"method": "GET",
				"header": [
					{
						"key": "dev",
						"value": "11",
						"type": "text"
					},
					{
						"key": "X-CSRFToken",
						"value": "zd3G9gcvBGglcfVXL12ujMLbKqC8nVUq",
						"type": "text",
						"disabled": true
					}
				],
				"body": {
					"mode": "formdata",
					"formdata": [
						{
							"key": "application",
							"value": "6",
							"type": "text"
						},
						{
							"key": "document_file",
							"type": "file",
							"src": "/C:/Users/cijog/Downloads/Rectangle 3463305.png"
						},
						{
							"key": "document_name",
							"value": "photo",
							"type": "text",
							"disabled": true
						},
						{
							"key": "document_type",
							"value": "photo",
							"type": "text"
						}
					]
				},
				"url": {
					"raw": "{{amai}}/api/membership/application-documents/",
					"host": [
						"{{amai}}"
					],
					"path": [
						"api",
						"membership",
						"application-documents",
						""
					],
					"query": [
						{
							"key": "",
							"value": null,
							"disabled": true
						}
					]
				}
			},
			"response": []
		},
		{
			"name": "membership application",
			"protocolProfileBehavior": {
				"disableBodyPruning": true
			},
			"request": {
				"method": "GET",
				"header": [
					{
						"key": "dev",
						"value": "2",
						"type": "text"
					}
				],
				"body": {
					"mode": "raw",
					"raw": "{\r\n    \"status\":\"approved\"\r\n}",
					"options": {
						"raw": {
							"language": "json"
						}
					}
				},
				"url": {
					"raw": "{{amai}}/api/membership/membership-applications/",
					"host": [
						"{{amai}}"
					],
					"path": [
						"api",
						"membership",
						"membership-applications",
						""
					]
				}
			},
			"response": []
		},
		{
			"name": "create zone",
			"request": {
				"method": "GET",
				"header": []
			},
			"response": []
		},
		{
			"name": "add address",
			"protocolProfileBehavior": {
				"disableBodyPruning": true
			},
			"request": {
				"method": "GET",
				"header": [
					{
						"key": "X-CSRFToken",
						"value": "zd3G9gcvBGglcfVXL12ujMLbKqC8nVUq",
						"type": "text",
						"disabled": true
					},
					{
						"key": "dev",
						"value": "2",
						"type": "text"
					}
				],
				"body": {
					"mode": "raw",
					"raw": "{\r\n  \"address_line1\": \"kochambatt\",\r\n  \"address_line2\": \"avalookunu\",\r\n  \"city\": \"string\",\r\n  \"state\": \"kerlaa\",\r\n  \"postal_code\": \"688006\",\r\n  \"district\":\"test\",\r\n  \"country\": \"india\",\r\n  \"is_primary\": true,\r\n  \"user\": \"7\"\r\n}\r\n",
					"options": {
						"raw": {
							"language": "json"
						}
					}
				},
				"url": {
					"raw": "{{amai}}/api/accounts/addresses/",
					"host": [
						"{{amai}}"
					],
					"path": [
						"api",
						"accounts",
						"addresses",
						""
					]
				}
			},
			"response": []
		},
		{
			"name": "logout",
			"request": {
				"method": "POST",
				"header": [
					{
						"key": "X-CSRFToken",
						"value": "haPg2fO4Lbze2nINvUKXfJWPznFndYOQ",
						"type": "text"
					}
				],
				"url": {
					"raw": "{{amai}}/api/accounts/logout/",
					"host": [
						"{{amai}}"
					],
					"path": [
						"api",
						"accounts",
						"logout",
						""
					]
				}
			},
			"response": []
		}
	],
	"variable": [
		{
			"key": "amai",
			"value": "",
			"type": "default"
		}
	]
}
