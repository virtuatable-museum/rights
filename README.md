# JDR-tools rights service

## Installation

### Pre-requisites

#### Softwares

You MUST ensure that ALL these software are installed in the given versions before installing and launching the application.

- RVM >= 1.29.1
- Ruby >= 2.3.1, installed via RVM
- Bundler gem >= 1.16.1
- MongoDB >= 3.2.13

#### Environment variable

You MUST ensure that ALL these environment variables are defined before passing to the next section and launching tests.

##### MongoDB URL

__Name :__ MONGODB_URL  
__meaning :__ This is the URL to contact the database linked to this instance of the rights service.  
__TYPE :__ String  
__Constraints :__ This variable MUST be a valid Mongo DB URL, otherwise the application will crash on startup.

##### Service URL

__Name :__ SERVICE_URL  
__Meaning :__ This is the URL to access to the current service.  
__Type :__ String  
__Constraints :__ You MUST NOT include the mapping path of the controller (/right). You MUST end it with a slash ('/') symbol.

### Procedures

#### Cloning the repository

Note that you MUST be a contributor to push code into our architecture. Contact us if you're not listed as contributor, but would want to bring your own brick to the system.

##### HTTP cloning

If your SSH key is not registered, you MUST clone in HTTP with the command `git clone https://github.com/jdr-tools/rights.git`

##### SSH cloning

If your SSH key is registered, you can use the following command `git clone git@github.com:jdr-tools/rights.git`

#### Launching the web server

We will consider that you have installed all required applications described in the above section.

```shell
bundle install
rackup -o 0.0.0.0 -p 3000
```

The above commands launch the server to listen on the 3000 port.

#### Launching the unit tests suite

To launch the unit test suite, juste execute the `rspec` command, the results will then be displayed.

## Common errors

### No gateway token error

__Scenario :__ A user tries to make a request on the service without providing a gateway token in the `token` field.
__Response status :__ 400 (Bad Request)  
__Response Type :__ JSON String.  
__Response body :__ `{"message": "bad_request"}`  
__Solution :__ Provide a gateway token in the `token` field.

### No application token given.

__Scenario :__ A user makes a request on the service without providing a `app_key` field in the parameters.  
__Response status :__ 400 (Bad Request)  
__Response format :__ JSON string.  
__Response body :__ `{'message': 'bad_request`}`  
__Solution :__ Provide your application key to make requests on the service.

### Unexisting gateway token given.

__Scenario :__ A user makes a request on the service providing a `token` field that can't be linked to any gateway.  
__Response status :__ 404 (Not Found)  
__Response format :__ JSON string.  
__Response body :__ `{'message': 'gateway_not_found`}`  
__Solution :__ Check the spelling of your gateway token and the existence of your gateway. Contact us for more informations.

### Unexisting application key given.

__Scenario :__ A user makes a request on the service providing a `app_key` field that can't be linked to any application.  
__Response status :__ 404 (Not Found)  
__Response format :__ JSON string.  
__Response body :__ `{'message': 'application_not_found`}`  
__Solution :__ Check the spelling of your application key and the existence of your application. Contact us for more informations.

## Available routes

### List of all the available rights

All parameters MUST be sent in the querystring.

#### Informations

__Verb :__ GET  
__URI :__ `/rights`

#### Nominal case

__Response status :__ 200 (OK)  
__Response type :__ JSON String.  
__Response body :__ See the example.

Example :

```
GET /rights

200 OK

{
  "count": 2,
  "items": [
    {
      'slug' => 'test_category',
      'count' => 1,
      'items' => [{'slug' => 'test_right', 'groups' => 1}]
    },
    {
      'slug' => 'other_category',
      'count' => 1,
      'items' => [{'slug' => 'another_random_right', 'groups' => 0}]
    }
  ]
}
```

__Notes :__
* The 'groups' field contains the number of groups linked to this right.

### Creation of a new right

All parameters MUST be sent in a JSON-encoded body. All querystring parameters will be ignored.

#### Informations

__Verb :__ POST  
__URI :__ `/rights`

#### Nominal case

__Response status :__ 201 (Created)  
__Response type :__ JSON String.  
__Response body :__ `{"message": "created"}`

### Slug not given as parameter.

__Scenario :__ A user makes a request on the service to create a new right, without providing the `slug` field.  
__Response status :__ 400 (Bad Request)  
__Response format :__ JSON string.  
__Response body :__ `{'message': 'bad_request`}`  
__Solution :__ Make the request again adding the slug as a parameter.

### Category ID not given as parameter.

__Scenario :__ A user makes a request on the service to create a new right, without providing the `category_id` field.  
__Response status :__ 400 (Bad Request)  
__Response format :__ JSON string.  
__Response body :__ `{'message': 'bad_request`}`  
__Solution :__ Make the request again adding the category ID as a parameter.

### Unexisting category identifier given.

__Scenario :__ A user makes a request on the service providing a `category_id` field that can't be linked to any category.  
__Response status :__ 404 (Not Found)  
__Response format :__ JSON string.  
__Response body :__ `{'message': 'category_not_found`}`  
__Solution :__ Check the spelling of your category ID and the existence of your category. Contact us for more informations.

### Deletion of a right

All parameters MUST be sent in the querystring.

#### Informations

__Verb :__ DELETE  
__URI :__ `/rights/<id>`

#### Nominal case

__Response status :__ 200 (OK)  
__Response type :__ JSON String.  
__Response body :__ `{"message": "deleted"}`

### Unexisting right given.

__Scenario :__ A user makes a request on the service providing an ID in the URL that doesn't belong to any right.  
__Response status :__ 404 (Not Found)  
__Response format :__ JSON string.  
__Response body :__ `{'message': 'right_not_found`}`  
__Solution :__ Check the spelling of your right ID and the existence of your right. Contact us for more informations.